import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/agent_repository.dart';
import '../../../core/storage/mcp_repository.dart';
import '../../../core/models/ai_agent.dart';
import '../../../core/models/mcp/mcp_server.dart';

/// Options for chat persistence: On, Off, and Disable
/// - On: Enable chat persistence
/// - Off: Disable chat persistence but follow global setting
/// - Disable: Force disable chat persistence (overrides global setting)
enum PersistOverride { on, off, disable }

class AddAgentViewModel extends ChangeNotifier {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController promptController = TextEditingController();

  // State variables representing all fields of AIAgent
  bool enableStream = true;
  bool isTopPEnabled = false;
  double topPValue = 1.0;
  bool isTopKEnabled = false;
  double topKValue = 40.0;
  bool isTemperatureEnabled = false;
  double temperatureValue = 0.7;
  int contextWindowValue = 60000;
  int conversationLengthValue = 10;
  int maxTokensValue = 4000;
  bool isCustomThinkingTokensEnabled = false;
  int customThinkingTokensValue = 0;
  ThinkingLevel thinkingLevel = ThinkingLevel.auto;
  bool agentConversations = false;
  List<MCPServer> availableMCPServers = [];
  final List<String> selectedMCPServerIds = [];
  PersistOverride persistOverride = PersistOverride.off;

  // Initialize with optional existing agent
  void initialize(AIAgent? agent) {
    if (agent != null) {
      nameController.text = agent.name;
      promptController.text = agent.config.systemPrompt;
      enableStream = agent.config.enableStream;

      if (agent.config.topP != null) {
        isTopPEnabled = true;
        topPValue = agent.config.topP!;
      }
      if (agent.config.topK != null) {
        isTopKEnabled = true;
        topKValue = agent.config.topK!;
      }
      if (agent.config.temperature != null) {
        isTemperatureEnabled = true;
        temperatureValue = agent.config.temperature!;
      }

      contextWindowValue = agent.config.contextWindow;
      conversationLengthValue = agent.config.conversationLength;
      maxTokensValue = agent.config.maxTokens;
      if (agent.config.customThinkingTokens != null) {
        isCustomThinkingTokensEnabled = true;
        customThinkingTokensValue = agent.config.customThinkingTokens!;
      }

      thinkingLevel = agent.config.thinkingLevel;
      agentConversations = agent.agentConversations;
      selectedMCPServerIds.addAll(agent.activeMCPServerIds);

      if (agent.persistChatSelection == null) {
        persistOverride = PersistOverride.off;
      } else {
        persistOverride = agent.persistChatSelection!
            ? PersistOverride.on
            : PersistOverride.disable;
      }
    }
    _loadMCPServers();
  }

  Future<void> _loadMCPServers() async {
    final mcpRepo = await MCPRepository.init();
    availableMCPServers = mcpRepo.getMCPServers();
    notifyListeners();
  }

  Future<void> saveAgent(AIAgent? existingAgent, BuildContext context) async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('agents.name'.tr())));
      return;
    }

    final repository = await AgentRepository.init();
    final newAgent = AIAgent(
      id: existingAgent?.id ?? const Uuid().v4(),
      name: nameController.text,
      config: RequestConfig(
        systemPrompt: promptController.text,
        enableStream: enableStream,
        topP: isTopPEnabled ? topPValue : null,
        topK: isTopKEnabled ? topKValue : null,
        temperature: isTemperatureEnabled ? temperatureValue : null,
        contextWindow: contextWindowValue,
        conversationLength: conversationLengthValue,
        maxTokens: maxTokensValue,
        customThinkingTokens: isCustomThinkingTokensEnabled
            ? customThinkingTokensValue
            : null,
        thinkingLevel: thinkingLevel,
      ),
      agentConversations: agentConversations,
      activeMCPServers: selectedMCPServerIds
          .map((id) => ActiveMCPServer(id: id, activeToolIds: []))
          .toList(),
      persistChatSelection: persistOverride == PersistOverride.off
          ? null
          : (persistOverride == PersistOverride.on ? true : false),
    );

    if (existingAgent != null) {
      await repository.updateAgent(newAgent);
    } else {
      await repository.addAgent(newAgent);
    }
  }

  void toggleMCPServer(String serverId) {
    if (selectedMCPServerIds.contains(serverId)) {
      selectedMCPServerIds.remove(serverId);
    } else {
      selectedMCPServerIds.add(serverId);
    }
    notifyListeners();
  }

  void setPersistOverride(PersistOverride value) {
    persistOverride = value;
    notifyListeners();
  }

  void toggleStream(bool value) {
    enableStream = value;
    notifyListeners();
  }

  void toggleTopP(bool value) {
    isTopPEnabled = value;
    notifyListeners();
  }

  void setTopPValue(double value) {
    topPValue = value;
    notifyListeners();
  }

  void toggleTopK(bool value) {
    isTopKEnabled = value;
    notifyListeners();
  }

  void setTopKValue(double value) {
    topKValue = value;
    notifyListeners();
  }

  void toggleTemperature(bool value) {
    isTemperatureEnabled = value;
    notifyListeners();
  }

  void setTemperatureValue(double value) {
    temperatureValue = value;
    notifyListeners();
  }

  void setContextWindowValue(int value) {
    contextWindowValue = value;
  }

  void setConversationLengthValue(int value) {
    conversationLengthValue = value;
  }

  void setMaxTokensValue(int value) {
    maxTokensValue = value;
  }

  void toggleCustomThinkingTokens(bool value) {
    isCustomThinkingTokensEnabled = value;
    notifyListeners();
  }

  void setCustomThinkingTokensValue(int value) {
    customThinkingTokensValue = value;
    notifyListeners();
  }

  void setThinkingLevel(ThinkingLevel value) {
    thinkingLevel = value;
    notifyListeners();
  }

  void toggleAgentConversations(bool value) {
    agentConversations = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    promptController.dispose();
    super.dispose();
  }
}
