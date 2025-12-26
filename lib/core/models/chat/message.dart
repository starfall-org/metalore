enum ChatRole {
  user,
  model,
  system,
  tool,
  developer,
} // developer is replacement for system role in OpenAI's official API

class MessageContent {
  final String content;
  final DateTime timestamp;
  final List<String> attachments;
  final String? reasoningContent;
  final List<String> aiMedia;

  MessageContent({
    required this.content,
    required this.timestamp,
    this.attachments = const [],
    this.reasoningContent,
    this.aiMedia = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'attachments': attachments,
      'reasoningContent': reasoningContent,
      'aiMedia': aiMedia,
    };
  }

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      content: (json['content'] ?? '') as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      reasoningContent: json['reasoningContent'] as String?,
      aiMedia:
          (json['aiMedia'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

class ChatMessage {
  /// auto-generated unique ID
  final String id;

  /// Role of the message
  final ChatRole role;

  /// All versions of this message (for regenerations or edits)
  final List<MessageContent> versions;

  /// Index of the currently active version
  final int currentVersionIndex;

  ChatMessage({
    required this.id,
    required this.role,
    List<MessageContent>? versions,
    this.currentVersionIndex = 0,
    // Parameters for convenience when creating a message with a single version
    String content = '',
    DateTime? timestamp,
    List<String> attachments = const [],
    String? reasoningContent,
    List<String> aiMedia = const [],
  }) : versions =
          versions ??
          [
            MessageContent(
              content: content,
              timestamp: timestamp ?? DateTime.now(),
              attachments: attachments,
              reasoningContent: reasoningContent,
              aiMedia: aiMedia,
            ),
          ];

  /// Getters for current version data (backward compatibility & convenience)
  MessageContent get current => versions[currentVersionIndex];
  String get content => current.content;
  DateTime get timestamp => current.timestamp;
  List<String> get attachments => current.attachments;
  String? get reasoningContent => current.reasoningContent;
  List<String> get aiMedia => current.aiMedia;

  ChatMessage copyWith({
    String? id,
    ChatRole? role,
    List<MessageContent>? versions,
    int? currentVersionIndex,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      versions: versions ?? this.versions,
      currentVersionIndex: currentVersionIndex ?? this.currentVersionIndex,
    );
  }

  /// Creates a copy of the message with a new version added and set as active
  ChatMessage addVersion(MessageContent content) {
    return copyWith(
      versions: [...versions, content],
      currentVersionIndex: versions.length,
    );
  }

  /// Creates a copy of the message with the content of the current version updated
  ChatMessage updateActiveContent(String newContent) {
    final updatedVersions = List<MessageContent>.from(versions);
    final currentV = updatedVersions[currentVersionIndex];
    updatedVersions[currentVersionIndex] = MessageContent(
      content: newContent,
      timestamp: currentV.timestamp,
      attachments: currentV.attachments,
      reasoningContent: currentV.reasoningContent,
      aiMedia: currentV.aiMedia,
    );
    return copyWith(versions: updatedVersions);
  }

  /// Switches to a specific version index
  ChatMessage switchVersion(int index) {
    if (index < 0 || index >= versions.length) return this;
    return copyWith(currentVersionIndex: index);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'versions': versions.map((v) => v.toJson()).toList(),
      'currentVersionIndex': currentVersionIndex,
      // Include deprecated fields at top level for backward compatibility with older parsers
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final versionsJson = json['versions'] as List<dynamic>?;
    final List<MessageContent> versions;

    if (versionsJson != null) {
      versions = versionsJson.map((v) => MessageContent.fromJson(v)).toList();
    } else {
      // Fallback for old format
      versions = [
        MessageContent(
          content: (json['content'] ?? '') as String,
          timestamp: DateTime.parse(json['timestamp'] as String),
          attachments:
              (json['attachments'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
          reasoningContent: json['reasoningContent'] as String?,
          aiMedia:
              (json['aiMedia'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
        )
      ];
    }

    return ChatMessage(
      id: json['id'] as String,
      role: ChatRole.values.firstWhere((e) => e.name == json['role']),
      versions: versions,
      currentVersionIndex: json['currentVersionIndex'] as int? ?? 0,
    );
  }
}

