import 'dart:convert';

/// App-wide preferences that are not language/theme related.
/// - persistChatSelection: when true, persist selected provider/model and enabled tools per conversation
/// - preferAgentSettings: when true, agent-level overrides take precedence over global preferences
class AppPreferences {
  final bool persistChatSelection;
  final bool preferAgentSettings;

  const AppPreferences({
    required this.persistChatSelection,
    required this.preferAgentSettings,
  });

  factory AppPreferences.defaults() {
    return const AppPreferences(
      persistChatSelection: false, // mặc định KHÔNG lưu
      preferAgentSettings: false,  // mặc định ưu tiên Global settings
    );
  }

  AppPreferences copyWith({
    bool? persistChatSelection,
    bool? preferAgentSettings,
  }) {
    return AppPreferences(
      persistChatSelection: persistChatSelection ?? this.persistChatSelection,
      preferAgentSettings: preferAgentSettings ?? this.preferAgentSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'persistChatSelection': persistChatSelection,
      'preferAgentSettings': preferAgentSettings,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      persistChatSelection: (json['persistChatSelection'] as bool?) ?? false,
      preferAgentSettings: (json['preferAgentSettings'] as bool?) ?? false,
    );
  }

  String toJsonString() => json.encode(toJson());

  factory AppPreferences.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) {
        return AppPreferences.defaults();
      }
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return AppPreferences.fromJson(data);
      }
      return AppPreferences.defaults();
    } catch (_) {
      return AppPreferences.defaults();
    }
  }
}