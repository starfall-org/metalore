import 'dart:convert';

class AIAgent {
  final String id;
  final String name;
  final String systemPrompt;
  final double? topP;
  final double? topK;
  final double? temperature;
  final int contextWindow;
  final int conversationLength;
  final int maxTokens;
  final List<String> activeMCPServerIds; // Renamed from activeMCPServer

  /// Optional per-agent preference override:
  /// - null: follow global preferences
  /// - true/false: override global preference for this agent
  final bool? persistChatSelection;

  AIAgent({
    required this.id,
    required this.name,
    required this.systemPrompt,
    this.topP,
    this.topK,
    this.temperature,
    this.contextWindow = 60000,
    this.conversationLength = 10,
    this.maxTokens = 4000,
    this.activeMCPServerIds = const [],
    this.persistChatSelection,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'systemPrompt': systemPrompt,
      'topP': topP,
      'topK': topK,
      'temperature': temperature,
      'contextWindow': contextWindow,
      'conversationLength': conversationLength,
      'maxTokens': maxTokens,
      'activeMCPServerIds': activeMCPServerIds,
      if (persistChatSelection != null)
        'persistChatSelection': persistChatSelection,
    };
  }

  factory AIAgent.fromJson(Map<String, dynamic> json) {
    return AIAgent(
      id: json['id'] as String,
      name: json['name'] as String,
      systemPrompt: json['systemPrompt'] as String,
      topP: json['topP'] as double?,
      topK: json['topK'] as double?,
      temperature: json['temperature'] as double?,
      contextWindow: json['contextWindow'] as int,
      conversationLength: json['conversationLength'] as int,
      maxTokens: json['maxTokens'] as int,
      activeMCPServerIds:
          (json['activeMCPServerIds'] as List?)?.cast<String>() ??
          (json['activeMCPServer'] as List?)
              ?.cast<String>() ?? // Backwards compatibility
          const [],
      persistChatSelection: json['persistChatSelection'] as bool?,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory AIAgent.fromJsonString(String jsonString) =>
      AIAgent.fromJson(json.decode(jsonString));
}
