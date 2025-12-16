import 'dart:typed_data';

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v);
  return null;
}

double? _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

List<double> _toDoubleList(dynamic v) {
  if (v is List) {
    return v.map((e) => _asDouble(e) ?? 0.0).toList();
  }
  return const [];
}

class OpenAIModelItem {
  final String id;
  final Map<String, dynamic> raw;
  OpenAIModelItem({required this.id, required this.raw});
  factory OpenAIModelItem.fromJson(Map<String, dynamic> json) {
    return OpenAIModelItem(
      id: json['id']?.toString() ?? json['name']?.toString() ?? 'unknown',
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIModelsResponse {
  final List<OpenAIModelItem> data;
  final Map<String, dynamic>? raw;
  OpenAIModelsResponse({required this.data, this.raw});
  factory OpenAIModelsResponse.fromJson(dynamic json) {
    if (json is List) {
      return OpenAIModelsResponse(
        data: json.map((e) => OpenAIModelItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        raw: null,
      );
    }
    if (json is Map<String, dynamic>) {
      final list = (json['data'] as List?) ?? const [];
      return OpenAIModelsResponse(
        data: list.map((e) => OpenAIModelItem.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
        raw: Map<String, dynamic>.from(json),
      );
    }
    return OpenAIModelsResponse(data: const [], raw: null);
  }
  Map<String, dynamic> toJson() => raw ?? {'data': data.map((e) => e.toJson()).toList()};
}

class OpenAIFunctionCall {
  final String? name;
  final String? arguments;
  final Map<String, dynamic> raw;
  OpenAIFunctionCall({this.name, this.arguments, required this.raw});
  factory OpenAIFunctionCall.fromJson(Map<String, dynamic> json) {
    return OpenAIFunctionCall(
      name: json['name']?.toString(),
      arguments: json['arguments']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIToolCall {
  final String? id;
  final String? type;
  final OpenAIFunctionCall? functionCall;
  final Map<String, dynamic> raw;
  OpenAIToolCall({this.id, this.type, this.functionCall, required this.raw});
  factory OpenAIToolCall.fromJson(Map<String, dynamic> json) {
    return OpenAIToolCall(
      id: json['id']?.toString(),
      type: json['type']?.toString(),
      functionCall: json['function'] is Map ? OpenAIFunctionCall.fromJson(Map<String, dynamic>.from(json['function'])) : null,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIChatMessage {
  final String role;
  final dynamic content;
  final List<OpenAIToolCall>? toolCalls;
  final Map<String, dynamic> raw;
  OpenAIChatMessage({
    required this.role,
    required this.content,
    this.toolCalls,
    required this.raw,
  });
  factory OpenAIChatMessage.fromJson(Map<String, dynamic> json) {
    List<OpenAIToolCall>? calls;
    final tc = json['tool_calls'];
    if (tc is List) {
      calls = tc.map((e) => OpenAIToolCall.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return OpenAIChatMessage(
      role: json['role']?.toString() ?? 'assistant',
      content: json['content'],
      toolCalls: calls,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIUsage {
  final int? promptTokens;
  final int? completionTokens;
  final int? totalTokens;
  final Map<String, dynamic> raw;
  OpenAIUsage({this.promptTokens, this.completionTokens, this.totalTokens, required this.raw});
  factory OpenAIUsage.fromJson(Map<String, dynamic> json) {
    return OpenAIUsage(
      promptTokens: _asInt(json['prompt_tokens']),
      completionTokens: _asInt(json['completion_tokens']),
      totalTokens: _asInt(json['total_tokens']),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIChatChoice {
  final int? index;
  final OpenAIChatMessage? message;
  final String? finishReason;
  final Map<String, dynamic>? logprobs;
  final Map<String, dynamic> raw;
  OpenAIChatChoice({this.index, this.message, this.finishReason, this.logprobs, required this.raw});
  factory OpenAIChatChoice.fromJson(Map<String, dynamic> json) {
    return OpenAIChatChoice(
      index: _asInt(json['index']),
      message: json['message'] is Map ? OpenAIChatMessage.fromJson(Map<String, dynamic>.from(json['message'])) : null,
      finishReason: json['finish_reason']?.toString(),
      logprobs: json['logprobs'] is Map ? Map<String, dynamic>.from(json['logprobs']) : null,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIChatCompletionsResponse {
  final String? id;
  final String? object;
  final int? created;
  final String? model;
  final List<OpenAIChatChoice> choices;
  final OpenAIUsage? usage;
  final Map<String, dynamic> raw;
  OpenAIChatCompletionsResponse({
    this.id,
    this.object,
    this.created,
    this.model,
    required this.choices,
    this.usage,
    required this.raw,
  });
  factory OpenAIChatCompletionsResponse.fromJson(Map<String, dynamic> json) {
    final ch = (json['choices'] as List? ?? const [])
        .map((e) => OpenAIChatChoice.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return OpenAIChatCompletionsResponse(
      id: json['id']?.toString(),
      object: json['object']?.toString(),
      created: _asInt(json['created']),
      model: json['model']?.toString(),
      choices: ch,
      usage: json['usage'] is Map ? OpenAIUsage.fromJson(Map<String, dynamic>.from(json['usage'])) : null,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIEmbeddingData {
  final int? index;
  final List<double> embedding;
  final String? object;
  final Map<String, dynamic> raw;
  OpenAIEmbeddingData({this.index, required this.embedding, this.object, required this.raw});
  factory OpenAIEmbeddingData.fromJson(Map<String, dynamic> json) {
    return OpenAIEmbeddingData(
      index: _asInt(json['index']),
      embedding: _toDoubleList(json['embedding']),
      object: json['object']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIEmbeddingsResponse {
  final String? object;
  final String? model;
  final List<OpenAIEmbeddingData> data;
  final OpenAIUsage? usage;
  final Map<String, dynamic> raw;
  OpenAIEmbeddingsResponse({
    this.object,
    this.model,
    required this.data,
    this.usage,
    required this.raw,
  });
  factory OpenAIEmbeddingsResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? const [])
        .map((e) => OpenAIEmbeddingData.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return OpenAIEmbeddingsResponse(
      object: json['object']?.toString(),
      model: json['model']?.toString(),
      data: list,
      usage: json['usage'] is Map ? OpenAIUsage.fromJson(Map<String, dynamic>.from(json['usage'])) : null,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIResponsesResponse {
  final Map<String, dynamic> raw;
  OpenAIResponsesResponse({required this.raw});
  String? get id => raw['id']?.toString();
  String? get model => raw['model']?.toString();
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
  factory OpenAIResponsesResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIResponsesResponse(raw: Map<String, dynamic>.from(json));
  }
}

class OpenAIAudioSpeechResponse {
  final Uint8List bytes;
  final String? contentType;
  OpenAIAudioSpeechResponse({required this.bytes, this.contentType});
}

class OpenAIAudioTranscriptionResponse {
  final String? text;
  final Map<String, dynamic> raw;
  OpenAIAudioTranscriptionResponse({this.text, required this.raw});
  factory OpenAIAudioTranscriptionResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIAudioTranscriptionResponse(
      text: json['text']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIAudioTranslationResponse {
  final String? text;
  final Map<String, dynamic> raw;
  OpenAIAudioTranslationResponse({this.text, required this.raw});
  factory OpenAIAudioTranslationResponse.fromJson(Map<String, dynamic> json) {
    return OpenAIAudioTranslationResponse(
      text: json['text']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIImageData {
  final String? url;
  final String? b64Json;
  final String? revisedPrompt;
  final Map<String, dynamic> raw;
  OpenAIImageData({this.url, this.b64Json, this.revisedPrompt, required this.raw});
  factory OpenAIImageData.fromJson(Map<String, dynamic> json) {
    return OpenAIImageData(
      url: json['url']?.toString(),
      b64Json: json['b64_json']?.toString(),
      revisedPrompt: json['revised_prompt']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIImagesResponse {
  final int? created;
  final List<OpenAIImageData> data;
  final Map<String, dynamic> raw;
  OpenAIImagesResponse({this.created, required this.data, required this.raw});
  factory OpenAIImagesResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? const [])
        .map((e) => OpenAIImageData.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return OpenAIImagesResponse(
      created: _asInt(json['created']),
      data: list,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIVideoData {
  final String? url;
  final String? b64Json;
  final Map<String, dynamic> raw;
  OpenAIVideoData({this.url, this.b64Json, required this.raw});
  factory OpenAIVideoData.fromJson(Map<String, dynamic> json) {
    return OpenAIVideoData(
      url: json['url']?.toString(),
      b64Json: json['b64_json']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}

class OpenAIVideosResponse {
  final List<OpenAIVideoData> data;
  final Map<String, dynamic> raw;
  OpenAIVideosResponse({required this.data, required this.raw});
  factory OpenAIVideosResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? const [])
        .map((e) => OpenAIVideoData.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return OpenAIVideosResponse(
      data: list,
      raw: Map<String, dynamic>.from(json),
    );
  }
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);
}