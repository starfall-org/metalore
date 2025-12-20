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
    if (agent.activeMCPServers.isEmpty) {
      return const <AIToolFunction>[];
    }
    try {
      final mcpRepository = await MCPRepository.init();
      final mcpService = MCPService();

      final servers = agent.activeMCPServers
          .map((i) => mcpRepository.getItem(i.id))
          .whereType<MCPServer>()
          .toList();

      if (servers.isEmpty) return const <AIToolFunction>[];

      // Build a map of allowed tools per server for easy lookup
      final allowedToolsMap = {
        for (var s in agent.activeMCPServers) s.id: s.activeToolIds.toSet(),
      };

      List<MCPTool> filterTools(List<MCPServer> serversToFilter) {
        return serversToFilter.expand((s) {
          final allowedNames = allowedToolsMap[s.id] ?? {};
          return s.tools.where(
            (t) => t.enabled && allowedNames.contains(t.name),
          );
        }).toList();
      }

      // Dùng cache nếu có
      List<MCPTool> cachedTools = filterTools(servers);

      if (cachedTools.isEmpty) {
        // Không có cache: fetch ngay và lưu lại
        final fetchedLists = await Future.wait(
          servers.map((s) async {
            try {
              final tools = await mcpService.fetchTools(s);
              final updatedServer = s.copyWith(tools: tools);
              await mcpRepository.updateItem(updatedServer);
              return updatedServer;
            } catch (_) {
              return s;
            }
          }),
        );
        cachedTools = filterTools(fetchedLists);
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
      enableSearch = selected.builtInTools.search;
      enableFetch = selected.builtInTools.urlContext;
    }

    final builtin = <AIToolFunction>[];
    if (enableSearch) {
      builtin.add(
        /// TODO
        const AIToolFunction(
          name: 'web_search',
          description:
              'Search the web for up-to-date information. Provide a specific query.',
          parameters: {
            'type': 'object',
            'properties': {
              'query': {
                'type': 'string',
                'description':
                    'Search query string describing the information needed.',
              },
              'topK': {
                'type': 'integer',
                'minimum': 1,
                'maximum': 50,
                'description':
                    'Number of search results to retrieve (default 5).',
              },
              'timeRange': {
                'type': 'string',
                'enum': ['any', 'day', 'week', 'month', 'year'],
                'description': 'Limit results to a recent time range.',
              },
            },
            'required': ['query'],
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
                'description': 'List of URLs to fetch.',
              },
              'maxBytes': {
                'type': 'integer',
                'minimum': 1024,
                'maximum': 10485760,
                'description': 'Maximum bytes to fetch per URL.',
              },
            },
            'required': ['urls'],
          },
        ),
      );
    }
    return builtin;
  }

  static Stream<String> generateStream({
    required String userText,
    required List<ChatMessage> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async* {
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

    final messagesWithCurrent = [
      ...history,
      ChatMessage(
        id: 'temp-user',
        role: ChatRole.user,
        content: userText,
        timestamp: DateTime.now(),
      ),
    ];

    var mcpTools = await _collectMcpTools(agent);
    if (allowedToolNames != null && allowedToolNames.isNotEmpty) {
      mcpTools = mcpTools
          .where((t) => allowedToolNames.contains(t.name))
          .toList();
    }

    final systemInstruction = agent.config.systemPrompt;

    switch (provider.type) {
      case ProviderType.google:
        final builtinTools = _collectGeminiBuiltinTools(provider, modelName);
        final allTools = [...mcpTools, ...builtinTools];

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: m.role.name,
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

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
                text:
                    '$systemInstruction\n\n${firstUserMsg.content.first.text}',
              ),
            ],
          );
        }

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
            stream: true,
          );
          await for (final resp in vertex.generateStream(aiRequest)) {
            yield resp.text;
          }
        } else {
          final studio = GoogleAIStudio(
            defaultModel: modelName,
            provider: provider,
          );
          final aiRequest = AIRequest(
            model: modelName,
            messages: aiMessages,
            tools: allTools,
            stream: true,
          );
          await for (final resp in studio.generateStream(aiRequest)) {
            yield resp.text;
          }
        }
        break;

      case ProviderType.openai:
        final routes = provider.openAIRoutes;
        final service = OpenAI(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          chatPath: routes.chatCompletion,
          modelsPath: routes.modelsRouteOrUrl,
          headers: provider.headers,
        );

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: m.role.name,
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        if (systemInstruction.isNotEmpty) {
          aiMessages.insert(
            0,
            AIMessage(
              role: 'system',
              content: [
                AIContent(type: AIContentType.text, text: systemInstruction),
              ],
            ),
          );
        }

        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          stream: true,
        );

        final stream = service.generateStream(aiRequest);
        await for (final resp in stream) {
          yield resp.text;
        }
        break;

      case ProviderType.anthropic:
        final service = Anthropic(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          headers: provider.headers,
        );

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: m.role.name,
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          stream: true,
          extra: systemInstruction.isNotEmpty
              ? {'system': systemInstruction}
              : {},
        );
        final stream = service.generateStream(aiRequest);
        await for (final resp in stream) {
          yield resp.text;
        }
        break;

      case ProviderType.ollama:
        final service = Ollama(
          baseUrl: provider.baseUrl,
          apiKey: provider.apiKey,
          headers: provider.headers,
        );

        final aiMessages = messagesWithCurrent
            .map(
              (m) => AIMessage(
                role: m.role.name,
                content: [AIContent(type: AIContentType.text, text: m.content)],
              ),
            )
            .toList();

        final aiRequest = AIRequest(
          model: modelName,
          messages: aiMessages,
          tools: mcpTools,
          stream: true,
        );
        final stream = service.generateStream(aiRequest);
        await for (final resp in stream) {
          yield resp.text;
        }
        break;
    }
  }

  static Future<String> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
    List<String>? allowedToolNames,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in generateStream(
      userText: userText,
      history: history,
      agent: agent,
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    )) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }
}
