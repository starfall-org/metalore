import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/models/ai_agent.dart';
import '../../../core/models/ai_model.dart';
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
import '../widgets/edit_message_dialog.dart';

import 'package:uuid/uuid.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';

part 'chat_viewmodel_actions.dart';
part 'chat_message_actions.dart';
part 'chat_attachment_actions.dart';
part 'chat_operations.dart';
part 'chat_edit_actions.dart';
part 'chat_ui_actions.dart';

class ChatViewModel extends ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  ChatRepository? chatRepository;
  Conversation? currentSession;
  AgentRepository? agentRepository;
  AIAgent? selectedAgent;
  bool isLoading = true;
  bool isGenerating = false;

  final List<String> pendingAttachments = [];

  // Right sidebar: attachments to inspect
  final List<String> inspectingAttachments = [];

  // Providers and model selection state
  ProviderRepository? providerRepository;
  List<Provider> providers = [];
  final Map<String, bool> providerCollapsed = {}; // true = collapsed
  String? selectedProviderName;
  String? selectedModelName;

  AIModel? get selectedAIModel {
    if (selectedProviderName == null || selectedModelName == null) return null;
    try {
      final provider =
          providers.firstWhere((p) => p.name == selectedProviderName);
      return provider.models.firstWhere((m) => m.name == selectedModelName);
    } catch (e) {
      return null;
    }
  }

  FlutterTts? tts;

  void notify() => notifyListeners();

  Future<void> initChat() async {
    chatRepository = await ChatRepository.init();
    final sessions = chatRepository!.getConversations();

    if (sessions.isNotEmpty) {
      currentSession = sessions.first;
      isLoading = false;
    } else {
      await createNewSession();
    }
    notifyListeners();
  }

  Future<void> loadSelectedAgent() async {
    agentRepository ??= await AgentRepository.init();
    final agent = await agentRepository!.getOrInitSelectedAgent();
    selectedAgent = agent;
    notifyListeners();
  }

  Future<void> refreshProviders() async {
    providerRepository ??= await ProviderRepository.init();
    providers = providerRepository!.getProviders();
    // Initialize collapse map entries for unseen providers
    for (final p in providers) {
      providerCollapsed.putIfAbsent(p.name, () => false);
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    providerCollapsed[providerName] = collapsed;
    notifyListeners();
  }

  bool shouldPersistSelections() {
    final prefs = AppPreferencesRepository.instance.currentPreferences;
    // If preferAgentSettings is on and agent has an override, use it
    if (selectedAgent?.persistChatSelection != null) {
      return selectedAgent!.persistChatSelection!;
    }
    return prefs.persistChatSelection;
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName = providerName;
    selectedModelName = modelName;

    // Persist selection into current conversation if preference allows
    if (currentSession != null && shouldPersistSelections()) {
      currentSession = currentSession!.copyWith(
        providerName: providerName,
        modelName: modelName,
        updatedAt: DateTime.now(),
      );
      // ignore: discarded_futures
      chatRepository?.saveConversation(currentSession!);
    }

    notifyListeners();
  }

  Future<void> createNewSession() async {
    final session = await chatRepository!.createConversation();
    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    isLoading = true;
    notifyListeners();

    final sessions = chatRepository!.getConversations();
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => sessions.first,
    );

    currentSession = session;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    tts?.stop();
    super.dispose();
  }
}
