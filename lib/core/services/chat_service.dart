import '../storage/provider_repository.dart';
import '../models/ai_agent.dart';
import '../models/chat/message.dart';
import '../models/provider.dart';
import '../models/ai/ai_dto.dart';
import '../models/ai_model.dart';
import 'ai/openai/openai.dart';
import 'ai/anthropic.dart';
import 'ai/ollama.dart';
import 'ai/google/aistudio.dart';
import 'ai/google/vertexai.dart';
import '../storage/mcp_repository.dart';
import 'mcp/mcp_service.dart';
import '../models/mcp/mcp_server.dart';

class ChatService {
  // Thu thập MCP tools ưu tiên cache; cập nhật khi dùng.
  static Future<List<AIToolFunction>> _collectMcpTools(AIAgent agent) async {
    if (agent.activeMCPServerIds.isEmpty) {
      return const <AIToolFunction>[];
    }
    try {
      final mcpRepository = await MCPRepository.init();
      final mcpService = MCPService();

      final servers = agent.activeMCPServerIds
          .map((id) => mcpRepository.getItem(id))
          .whereType<MCPServer>()
          .toList();
      if (servers.isEmpty) return const <AIToolFunction>[];

      // Dùng cache nếu có
      List<MCPTool> cachedTools =
          servers.expand((s) => s.tools).where((t) => t.enabled).toList();

      if (cachedTools.isEmpty) {
        // Không có cache: fetch ngay và lưu lại
        final fetchedLists = await Future.wait(
          servers.map((s) async {
            try {
              final tools = await mcpService.fetchTools(s);
              await mcpRepository.updateItem(s.copyWith(tools: tools));
              return tools;
            } catch (_) {
              return <MCPTool>[];
            }
          }),
        );
        cachedTools =
            fetchedLists.expand((e) => e).where((t) => t.enabled).toList();
      } else {
        // Có cache: làm mới ở nền khi được dùng, không chặn luồng chat
        // ignore: discarded_futures
        Future(() async {
          for (final s in servers) {
            try {
              final tools = await mcpService.fetchTools(s);
              await mcpRepository.updateItem(s.copyWith(tools: tools));
            } catch (_) {}
          }
        });
      }

      // Khử trùng lặp theo tên tool
      final map = <String, AIToolFunction>{};
      for (final t in cachedTools) {
        map[t.name] = AIToolFunction(
          name: t.name,
          description: t.description,
          parameters: t.inputSchema.toJson(),
        );
      }
      return map.values.toList();
    } catch (_) {
      return const <AIToolFunction>[];
    }
  }

  // Built-in Gemini tools toggling based on AIModel flags or model name
  static List<AIToolFunction> _collectGeminiBuiltinTools(
    Provider provider,
    String modelName,
  ) {
    final lower = modelName.toLowerCase();
    bool defaultGemini = lower.contains('gemini');

    bool enableSearch = defaultGemini;
    bool enableFetch = defaultGemini;

    // If model is defined in provider, use its flags
    AIModel? selected;
    for (final m in provider.models) {
      if (m.name.toLowerCase() == lower) {
        selected = m;
        break;
      }
    }
    if (selected != null) {
      enableSearch = selected.builtinWebSearch;
      enableFetch = selected.builtinWebFetch;
    }

    final builtin = <AIToolFunction>[];
    if (enableSearch) {
      builtin.add(
        const AIToolFunction(
          name: 'web_search',
          description:
              'Search the web for up-to-date information. Provide a specific query.',
          parameters: {
            'type': 'object',
            'properties': {
              'query': {
                'type': 'string',
                'description': 'Search query string describing the information needed.'
              },
              'topK': {
                'type': 'integer',
                'minimum': 1,
                'maximum': 50,
                'description': 'Number of search results to retrieve (default 5).'
              },
              'timeRange': {
                'type': 'string',
                'enum': ['any', 'day', 'week', 'month', 'year'],
                'description': 'Limit results to a recent time range.'
              }
            },
            'required': ['query']
          },
        ),
      );
    }
    if (enableFetch) {
      builtin.add(
        const AIToolFunction(
          name: 'web_fetch',
          description:
              'Fetch and retrieve the content of one or more web pages to ground your answer.',
          parameters: {
            'type': 'object',
            'properties': {
              'urls': {
                'type': 'array',
                'items': {'type': 'string'},
                'minItems': 1,
                'description': 'List of URLs to fetch.'
              },
              'maxBytes': {
                'type': 'integer',
                'minimum': 1024,
                'maximum': 10485760,
                'description': 'Maximum bytes to fetch per URL.'
              }
            },
            'required': ['urls']
          },
        ),
      );
    }
    return builtin;
  }

  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async {
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configuration found. Please add a provider in Settings.',
      );
    }

    final provider = providers.firstWhere(
      (p) => p.name == providerName,
      orElse: () => throw Exception('Provider "$providerName" not found.'),
    );

    // Ensure model exists in provider (optional validation)
    // final model = provider.models.firstWhere(
    //   (m) => m.name == modelName,
    //   orElse: () => throw Exception('Model "$modelName" not found for provider.'),
    // );

    final messagesWithCurrent = [
      ...history,
      ChatMessage(
        id: 'temp-user',
        role: ChatRole.user,
        content: userText,
        timestamp: DateTime.now(),
      ),
    ];

    // Collect MCP tools configured for this agent
    var mcpTools = await _collectMcpTools(agent);
    // If caller provides an allowlist of tool names (per-conversation persistence),
    // further restrict the tools to only those listed.
    if (allowedToolNames != null && allowedToolNames.isNotEmpty) {
      mcpTools =
          mcpTools.where((t) => allowedToolNames.contains(t.name)).toList();
    }

    final systemInstruction = agent.systemPrompt;

    switch (provider.type) {
      case ProviderType.google:
        // Tự động bổ sung 2 built-in tools cho Gemini (bật/tắt bằng AIModel flags)
        final builtinTools = _collectGeminiBuiltinTools(provider, modelName);
        final allTools = [
          ...mcpTools,
          ...builtinTools,
        ];

        // Chuẩn hóa messages và nhúng system instruction vào user message đầu
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();

        if (systemInstruction.isNotEmpty && aiMessages.isNotEmpty) {
          final firstUserMsg = aiMessages.firstWhere(
            (m) => m.role == 'user',
            orElse: () => aiMessages.first,
          );
          final idx = aiMessages.indexOf(firstUserMsg);
          aiMessages[idx] = AIMessage(
            role: firstUserMsg.role,
            content: [
              AIContent(
                type: AIContentType.text,
                text: '$systemInstruction\n\n${firstUserMsg.content.first.text}',
              ),
            ],
          );
        }

        // Chọn dịch vụ: Vertex AI nếu có cấu hình đầy đủ, ngược lại AI Studio
        final vx = provider.vertexAIConfig;
        if (vx != null && vx.projectId.isNotEmpty) {
          final vertex = GoogleVertexAI(
            defaultModel: modelName,
            provider: provider,
            projectId: vx.projectId,
            location: vx.location,
          );
          final aiRequest = AIRequest(
            model: modelName,
            messages: aiMessages,
            tools: allTools,
          );
          final resp = await vertex.generate(aiRequest);
          return resp.text;
        } else {
          final studio = GoogleAIStudio(
            defaultModel: modelName,
            provider: provider,
          );
          final aiRequest = AIRequest(
            model: modelName,
            messages: aiMessages,
            tools: allTools,
          );
          final resp = await studio.generate(aiRequest);
          return resp.text;
        }

      case ProviderType.openai:
        final routes = provider.openAIRoutes;
        final service = OpenAI(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          chatPath: routes.chatCompletion,
          responsesPath: routes.responses,
          modelsPath: routes.models,
          embeddingsPath: routes.embeddings,
          imagesGenerationsPath: routes.imagesGenerations,
          imagesEditsPath: routes.imagesEdits,
          videosPath: routes.videos,
          audioSpeechPath: routes.audioSpeech,
          headers: provider.headers,
        );
        
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();
        
        // Add system instruction as first message if present
        if (systemInstruction.isNotEmpty) {
          aiMessages.insert(
            0,
            AIMessage(
              role: 'system',
              content: [AIContent(type: AIContentType.text, text: systemInstruction)],
            ),
          );
        }
        
        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
        );
        
        final resp = await service.generate(aiRequest);
        return resp.text;

      case ProviderType.anthropic:
        final routes = provider.anthropicRoutes;
        final service = Anthropic(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          messagesPath: routes.messages,
          modelsPath: routes.models,
          anthropicVersion: routes.anthropicVersion,
          headers: provider.headers,
        );
        
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();
        
        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          extra: systemInstruction.isNotEmpty ? {'system': systemInstruction} : {},
        );
        final resp = await service.generate(aiRequest);
        return resp.text;

      case ProviderType.ollama:
        final routes = provider.ollamaRoutes;
        final service = Ollama(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          chatPath: routes.chat,
          tagsPath: routes.tags,
          embeddingsPath: routes.embeddings,
          headers: provider.headers,
        );
        
        final aiMessages = messagesWithCurrent.map((m) => AIMessage(
          role: m.role.name,
          content: [AIContent(type: AIContentType.text, text: m.content)],
        )).toList();
        
        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
        );
        final resp = await service.generate(aiRequest);
        return resp.text;
    }
  }
}
