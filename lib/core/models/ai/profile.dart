import 'dart:convert';

enum ThinkingLevel { none, low, medium, high, auto, custom }

class AIProfile {
  final String id;
  final String name;
  final String? icon;
  final AiConfig config;
  final bool profileConversations;
  final List<String?> conversationIds;
  final List<ActiveMCPServer> activeMCPServers;
  final List<String> activeBuiltInTools;
  final bool? persistChatSelection;

  AIProfile({
    required this.id,
    required this.name,
    this.icon,
    required this.config,
    this.profileConversations = false,
    this.conversationIds = const [],
    this.activeMCPServers = const [],
    this.activeBuiltInTools = const [],
    this.persistChatSelection,
  });

  List<String> get activeMCPServerIds =>
      activeMCPServers.map((e) => e.id).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      ...config.toJson(),
      'profileConversations': profileConversations,
      'conversa tionIds': conversationIds,
      'activeMCPServers': activeMCPServers.map((e) => e.toJson()).toList(),
      'activeBuiltInTools': activeBuiltInTools,
      if (persistChatSelection != null)
        'persistChatSelection': persistChatSelection,
    };
  }

  factory AIProfile.fromJson(Map<String, dynamic> json) {
    return AIProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      config: AiConfig(
        systemPrompt: json['systemPrompt'] as String? ?? '',
        enableStream: json['enableStream'] as bool? ?? true,
        topP: json['topP'] as double?,
        topK: json['topK'] as double?,
        temperature: json['temperature'] as double?,
        contextWindow: json['contextWindow'] as int? ?? 60000,
        conversationLength: json['conversationLength'] as int? ?? 10,
        maxTokens: json['maxTokens'] as int? ?? 4000,
        customThinkingTokens: json['customThinkingTokens'] as int?,
        thinkingLevel: ThinkingLevel.values.firstWhere(
          (e) => e.name == json['thinkingLevel'] as String,
          orElse: () => ThinkingLevel.auto,
        ),
      ),
      conversationIds:
          (json['conversationIds'] as List?)?.cast<String>() ?? const [],
      activeMCPServers:
          (json['activeMCPServers'] as List?)
              ?.map((e) => ActiveMCPServer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      activeBuiltInTools:
          (json['activeBuiltInTools'] as List?)?.cast<String>() ?? const [],
      persistChatSelection: json['persistChatSelection'] as bool?,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory AIProfile.fromJsonString(String jsonString) =>
      AIProfile.fromJson(json.decode(jsonString));
}

class AiConfig {
  final String systemPrompt;
  final bool enableStream;
  final double? topP;
  final double? topK;
  final double? temperature;
  final int contextWindow;
  final int conversationLength;
  final int maxTokens;
  final int? customThinkingTokens;
  final ThinkingLevel thinkingLevel;

  AiConfig({
    required this.systemPrompt,
    required this.enableStream,
    this.topP,
    this.topK,
    this.temperature,
    this.contextWindow = 60000,
    this.conversationLength = 10,
    this.maxTokens = 4000,
    this.customThinkingTokens,
    this.thinkingLevel = ThinkingLevel.auto,
  });

  Map<String, dynamic> toJson() {
    return {
      'systemPrompt': systemPrompt,
      'enableStream': enableStream,
      'topP': topP,
      'topK': topK,
      'temperature': temperature,
      'contextWindow': contextWindow,
      'conversationLength': conversationLength,
      'maxTokens': maxTokens,
      'customThinkingTokens': customThinkingTokens,
      'thinkingLevel': thinkingLevel.name,
    };
  }
}

class ActiveMCPServer {
  final String id;
  final List<String> activeToolIds;

  ActiveMCPServer({required this.id, required this.activeToolIds});

  Map<String, dynamic> toJson() {
    return {'id': id, 'activeToolIds': activeToolIds};
  }

  factory ActiveMCPServer.fromJson(Map<String, dynamic> json) {
    return ActiveMCPServer(
      id: json['id'] as String,
      activeToolIds: (json['activeToolIds'] as List?)?.cast<String>() ?? [],
    );
  }
}
