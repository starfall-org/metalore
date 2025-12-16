int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v);
  return null;
}

class AnthropicModelItem {
  final String id;
  final Map<String, dynamic> raw;
  AnthropicModelItem({required this.id, required this.raw});
  factory AnthropicModelItem.fromJson(Map<String, dynamic> json) {
    return AnthropicModelItem(
      id: json['id']?.toString() ?? 'unknown',
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class AnthropicModelsResponse {
  final List<AnthropicModelItem> data;
  final Map<String, dynamic>? raw;
  AnthropicModelsResponse({required this.data, this.raw});
  factory AnthropicModelsResponse.fromJson(dynamic json) {
    if (json is List) {
      return AnthropicModelsResponse(
        data: json
            .whereType<Map>()
            .map(
              (e) => AnthropicModelItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        raw: null,
      );
    }
    if (json is Map<String, dynamic>) {
      final list = (json['data'] as List?) ?? const [];
      return AnthropicModelsResponse(
        data: list
            .whereType<Map>()
            .map(
              (e) => AnthropicModelItem.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList(),
        raw: Map<String, dynamic>.from(json),
      );
    }
    return AnthropicModelsResponse(data: const [], raw: null);
  }
  Map<String, dynamic> toJson() =>
      raw ?? {'data': data.map((e) => e.toJson()).toList()};
}

class AnthropicUsage {
  final int? inputTokens;
  final int? outputTokens;
  final Map<String, dynamic> raw;
  AnthropicUsage({this.inputTokens, this.outputTokens, required this.raw});
  int? get totalTokens {
    if (inputTokens == null && outputTokens == null) return null;
    return (inputTokens ?? 0) + (outputTokens ?? 0);
  }

  factory AnthropicUsage.fromJson(Map<String, dynamic> json) {
    return AnthropicUsage(
      inputTokens: _asInt(json['input_tokens']),
      outputTokens: _asInt(json['output_tokens']),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class AnthropicContentBlock {
  final String? type; // 'text', 'tool_use', 'tool_result', etc.
  final String? text; // when type == 'text'
  final Map<String, dynamic> raw;
  AnthropicContentBlock({this.type, this.text, required this.raw});
  factory AnthropicContentBlock.fromJson(Map<String, dynamic> json) {
    return AnthropicContentBlock(
      type: json['type']?.toString(),
      text: json['text']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class AnthropicMessagesResponse {
  final String? id;
  final String? type; // typically 'message'
  final String? role; // 'assistant'
  final String? model;
  final String? stopReason;
  final String? stopSequence;
  final List<AnthropicContentBlock> content;
  final AnthropicUsage? usage;
  final Map<String, dynamic> raw;

  AnthropicMessagesResponse({
    this.id,
    this.type,
    this.role,
    this.model,
    this.stopReason,
    this.stopSequence,
    required this.content,
    this.usage,
    required this.raw,
  });

  factory AnthropicMessagesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['content'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (e) => AnthropicContentBlock.fromJson(Map<String, dynamic>.from(e)),
        )
        .toList();
    return AnthropicMessagesResponse(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      role: json['role']?.toString(),
      model: json['model']?.toString(),
      stopReason: json['stop_reason']?.toString(),
      stopSequence: json['stop_sequence']?.toString(),
      content: list,
      usage: json['usage'] is Map
          ? AnthropicUsage.fromJson(Map<String, dynamic>.from(json['usage']))
          : null,
      raw: Map<String, dynamic>.from(json),
    );
  }

  /// Convenience to extract concatenated text from text content blocks
  String get text {
    final texts = content
        .where(
          (c) =>
              (c.type == null || c.type == 'text') &&
              (c.text?.isNotEmpty ?? false),
        )
        .map((c) => c.text!)
        .toList();
    return texts.join('\n');
  }

  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}
