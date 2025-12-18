import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/models/ai_agent.dart';
import '../../../core/models/chat/message.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/models/chat/conversation.dart';
import '../../../core/storage/agent_repository.dart';
import '../../../core/storage/chat_repository.dart';
import '../../../core/storage/provider_repository.dart';
import '../../../core/models/provider.dart';
import '../../../core/storage/app_preferences_repository.dart';
import '../../../core/storage/mcp_repository.dart';
import '../../../core/models/mcp/mcp_server.dart';

class ChatViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatRepository? _chatRepository;
  Conversation? _currentSession;
  AgentRepository? _agentRepository;
  AIAgent? _selectedAgent;
  bool _isLoading = true;
  bool _isGenerating = false;

  final List<String> _pendingAttachments = [];

  // Providers and model selection state
  ProviderRepository? _providerRepository;
  List<Provider> _providers = [];
  final Map<String, bool> _providerCollapsed = {}; // true = collapsed
  String? _selectedProviderName;
  String? _selectedModelName;

  FlutterTts? _tts;

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;
  TextEditingController get textController => _textController;
  ScrollController get scrollController => _scrollController;
  Conversation? get currentSession => _currentSession;
  AIAgent? get selectedAgent => _selectedAgent;
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  List<String> get pendingAttachments => _pendingAttachments;

  // Expose providers/model selection state
  List<Provider> get providers => _providers;
  Map<String, bool> get providerCollapsed => _providerCollapsed;
  String? get selectedProviderName => _selectedProviderName;
  String? get selectedModelName => _selectedModelName;

  Future<void> initChat() async {
    _chatRepository = await ChatRepository.init();
    final sessions = _chatRepository!.getConversations();

    if (sessions.isNotEmpty) {
      _currentSession = sessions.first;
      _isLoading = false;
    } else {
      await createNewSession();
    }
    notifyListeners();
  }

  Future<void> loadSelectedAgent() async {
    _agentRepository ??= await AgentRepository.init();
    final agent = await _agentRepository!.getOrInitSelectedAgent();
    _selectedAgent = agent;
    notifyListeners();
  }

  Future<void> refreshProviders() async {
    _providerRepository ??= await ProviderRepository.init();
    _providers = _providerRepository!.getProviders();
    // Initialize collapse map entries for unseen providers
    for (final p in _providers) {
      _providerCollapsed.putIfAbsent(p.name, () => false);
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    _providerCollapsed[providerName] = collapsed;
    notifyListeners();
  }

  bool _shouldPersistSelections() {
    final prefs = AppPreferencesRepository.instance.currentPreferences;
    // If preferAgentSettings is on and agent has an override, use it
    if (prefs.preferAgentSettings && _selectedAgent?.persistChatSelection != null) {
      return _selectedAgent!.persistChatSelection!;
    }
    return prefs.persistChatSelection;
  }

  Future<List<String>> _snapshotEnabledToolNames(AIAgent agent) async {
    try {
      final mcpRepo = await MCPRepository.init();
      final servers = agent.activeMCPServerIds
          .map((id) => mcpRepo.getItem(id))
          .whereType<MCPServer>()
          .toList();
      final names = <String>{};
      for (final s in servers) {
        for (final t in s.tools) {
          if (t.enabled) names.add(t.name);
        }
      }
      return names.toList();
    } catch (_) {
      return const <String>[];
    }
  }

  void selectModel(String providerName, String modelName) {
    _selectedProviderName = providerName;
    _selectedModelName = modelName;

    // Persist selection into current conversation if preference allows
    if (_currentSession != null && _shouldPersistSelections()) {
      _currentSession = _currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      // ignore: discarded_futures
      _chatRepository?.saveConversation(_currentSession!);
    }

    notifyListeners();
  }

  Future<void> createNewSession() async {
    final session = await _chatRepository!.createConversation();
    _currentSession = session;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    _isLoading = true;
    notifyListeners();

    final sessions = _chatRepository!.getConversations();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    _currentSession = session;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> handleSubmitted(String text, BuildContext context) async {
    if (((text.trim().isEmpty) && _pendingAttachments.isEmpty) ||
        _currentSession == null) {
      return;
    }

    final List<String> attachments = List<String>.from(_pendingAttachments);
    _textController.clear();

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      timestamp: DateTime.now(),
      attachments: attachments,
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, userMessage],
      updatedAt: DateTime.now(),
    );
    _isGenerating = true;
    _pendingAttachments.clear();
    notifyListeners();

    if (_currentSession!.messages.length == 1) {
      final base = text.isNotEmpty
          ? text
          : (attachments.isNotEmpty
                ? 'attachments.title_count'.tr(
                    namedArgs: {'count': attachments.length.toString()},
                  )
                : 'drawer.new_chat'.tr());
      final title = base.length > 30 ? '${base.substring(0, 30)}...' : base;
      _currentSession = _currentSession!.copyWith(title: title);
    }

    await _chatRepository!.saveConversation(_currentSession!);
    scrollToBottom();

    String modelInput = text;
    if (attachments.isNotEmpty) {
      final names = attachments.map((p) => p.split('/').last).join(', ');
      modelInput =
          '${modelInput.isEmpty ? '' : '$modelInput\n'}[Attachments: $names]';
    }

    // Select provider/model based on preferences (persisted per conversation if enabled)
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();

    final persist = _shouldPersistSelections();
    String providerName;
    String modelName;

    if (persist &&
        _currentSession?.providerName != null &&
        _currentSession?.modelName != null) {
      providerName = _currentSession!.providerName!;
      modelName = _currentSession!.modelName!;
    } else {
      providerName =
          _selectedProviderName ?? (providers.isNotEmpty ? providers.first.name : '');
      modelName = _selectedModelName ??
          ((providers.isNotEmpty && providers.first.models.isNotEmpty)
              ? providers.first.models.first.name
              : '');
      // If persistence is enabled, store selection on the conversation
      if (_currentSession != null && persist) {
        _currentSession = _currentSession!.copyWith(
          providerName: providerName,
          modelName: modelName,
          updatedAt: DateTime.now(),
        );
        await _chatRepository!.saveConversation(_currentSession!);
      }
    }

    // Prepare allowed tool names if persistence is enabled
    List<String>? allowedToolNames;
    if (persist) {
      if (_currentSession!.enabledToolNames == null) {
        // Snapshot currently enabled MCP tools from agent for this conversation
        final agent = _selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              systemPrompt: '',
            );
        final names = await _snapshotEnabledToolNames(agent);
        _currentSession = _currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await _chatRepository!.saveConversation(_currentSession!);
      }
      allowedToolNames = _currentSession!.enabledToolNames;
    }

    final reply = await ChatService.generateReply(
      userText: modelInput,
      history: _currentSession!.messages,
      agent: _selectedAgent ??
          AIAgent(
            id: const Uuid().v4(),
            name: 'Default Agent',
            systemPrompt: '',
          ),
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    );

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    _currentSession = _currentSession!.copyWith(
      messages: [..._currentSession!.messages, modelMessage],
      updatedAt: DateTime.now(),
    );
    _isGenerating = false;
    notifyListeners();

    await _chatRepository!.saveConversation(_currentSession!);
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> pickAttachments(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      final paths = result?.paths.whereType<String>().toList() ?? const [];
      if (paths.isEmpty) return;

      for (final p in paths) {
        if (!_pendingAttachments.contains(p)) {
          _pendingAttachments.add(p);
        }
      }
      notifyListeners();
    } catch (e) {
      // Check if context is still valid before using it
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'chat.unable_pick'.tr(namedArgs: {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  void removeAttachmentAt(int index) {
    if (index < 0 || index >= _pendingAttachments.length) return;
    _pendingAttachments.removeAt(index);
    notifyListeners();
  }

  String getTranscript() {
    if (_currentSession == null) return '';
    return _currentSession!.messages
        .map((m) {
          final who = m.role == ChatRole.user
              ? 'role.you'.tr(context: _scaffoldKey.currentContext!)
              : (m.role == ChatRole.model
                    ? (_selectedAgent?.name ?? 'AI')
                    : 'role.system'.tr(context: _scaffoldKey.currentContext!));
          return '$who: ${m.content}';
        })
        .join('\n\n');
  }

  Future<void> copyTranscript(BuildContext context) async {
    final txt = getTranscript();
    if (txt.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: txt));

    // Check if context is still valid before using it
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('chat.copied'.tr())));
    }
  }

  Future<void> clearChat() async {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(
      messages: [],
      updatedAt: DateTime.now(),
    );
    notifyListeners();
    await _chatRepository!.saveConversation(_currentSession!);
  }

  Future<void> regenerateLast(BuildContext context) async {
    if (_currentSession == null || _currentSession!.messages.isEmpty) return;

    final msgs = _currentSession!.messages;
    int lastUserIndex = -1;
    for (int i = msgs.length - 1; i >= 0; i--) {
      if (msgs[i].role == ChatRole.user) {
        lastUserIndex = i;
        break;
      }
    }
    if (lastUserIndex == -1) {
      // Check if context is still valid before using it
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('chat.no_user_to_regen'.tr())));
      }
      return;
    }

    final userText = msgs[lastUserIndex].content;
    final history = msgs.take(lastUserIndex).toList();

    _isGenerating = true;
    notifyListeners();

    // Resolve provider/model for regeneration with persistence consideration
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();

    final persist = _shouldPersistSelections();
    String providerName;
    String modelName;

    if (persist &&
        _currentSession?.providerName != null &&
        _currentSession?.modelName != null) {
      providerName = _currentSession!.providerName!;
      modelName = _currentSession!.modelName!;
    } else {
      providerName =
          _selectedProviderName ?? (providers.isNotEmpty ? providers.first.name : '');
      modelName = _selectedModelName ??
          ((providers.isNotEmpty && providers.first.models.isNotEmpty)
              ? providers.first.models.first.name
              : '');
      if (_currentSession != null && persist) {
        _currentSession = _currentSession!.copyWith(
          providerName: providerName,
          modelName: modelName,
          updatedAt: DateTime.now(),
        );
        await _chatRepository!.saveConversation(_currentSession!);
      }
    }

    // Allowed tools from conversation if persisted
    List<String>? allowedToolNames;
    if (persist) {
      if (_currentSession!.enabledToolNames == null) {
        final agent = _selectedAgent ??
            AIAgent(
              id: const Uuid().v4(),
              name: 'Default Agent',
              systemPrompt: '',
            );
        final names = await _snapshotEnabledToolNames(agent);
        _currentSession = _currentSession!.copyWith(
          enabledToolNames: names,
          updatedAt: DateTime.now(),
        );
        await _chatRepository!.saveConversation(_currentSession!);
      }
      allowedToolNames = _currentSession!.enabledToolNames;
    }

    final reply = await ChatService.generateReply(
      userText: userText,
      history: history,
      agent: _selectedAgent ??
          AIAgent(
            id: const Uuid().v4(),
            name: 'Default Agent',
            systemPrompt: '',
          ),
      providerName: providerName,
      modelName: modelName,
      allowedToolNames: allowedToolNames,
    );

    final modelMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.model,
      content: reply,
      timestamp: DateTime.now(),
    );

    // Cắt bỏ các câu trả lời model sau lastUser (nếu có) rồi thêm câu trả lời mới
    final newMessages = [...history, msgs[lastUserIndex], modelMessage];

    _currentSession = _currentSession!.copyWith(
      messages: newMessages,
      updatedAt: DateTime.now(),
    );
    _isGenerating = false;
    notifyListeners();

    await _chatRepository!.saveConversation(_currentSession!);
    scrollToBottom();
  }

  Future<void> speakLastModelMessage() async {
    if (_currentSession == null || _currentSession!.messages.isEmpty) return;
    final lastModel = _currentSession!.messages.lastWhere(
      (m) => m.role == ChatRole.model,
      orElse: () => ChatMessage(
        id: '',
        role: ChatRole.model,
        content: '',
        timestamp: DateTime.now(),
      ),
    );
    if (lastModel.content.isEmpty) return;
    _tts ??= FlutterTts();
    await _tts!.speak(lastModel.content);
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _tts?.stop();
  }
}
