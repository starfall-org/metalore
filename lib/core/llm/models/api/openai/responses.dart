import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

// Response-related classes
@JsonSerializable()
class OpenAiResponses {
  final String id;
  final String object;
  final int created_at;
  final String model;
  final String status;
  final ErrorInfo? error;
  final IncompleteDetails? incomplete_details;
  final List<ResponseItem> output;
  final ResponsesUsage usage;

  OpenAiResponses({
    required this.id,
    required this.object,
    required this.created_at,
    required this.model,
    required this.status,
    this.error,
    this.incomplete_details,
    required this.output,
    required this.usage,
  });

  factory OpenAiResponses.fromJson(Map<String, dynamic> json) =>
      _$OpenAiResponsesFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiResponsesToJson(this);
}

@JsonSerializable()
class ResponseItem {
  final String id;
  final String type;
  final String role;
  final List<MessageContent> content;
  final String status;

  ResponseItem({
    required this.id,
    required this.type,
    required this.role,
    required this.content,
    required this.status,
  });

  factory ResponseItem.fromJson(Map<String, dynamic> json) =>
      _$ResponseItemFromJson(json);

  Map<String, dynamic> toJson() => _$ResponseItemToJson(this);
}

@JsonSerializable()
class MessageContent {
  final String type;
  final String text;
  final List<Annotation>? annotations;
  final Logprobs? logprobs;

  MessageContent({
    required this.type,
    required this.text,
    this.annotations,
    this.logprobs,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) =>
      _$MessageContentFromJson(json);

  Map<String, dynamic> toJson() => _$MessageContentToJson(this);
}

@JsonSerializable()
class Annotation {
  final String type;
  final String text;
  final int start_index;
  final int end_index;
  final String? file_id;
  final String? title;

  Annotation({
    required this.type,
    required this.text,
    required this.start_index,
    required this.end_index,
    this.file_id,
    this.title,
  });

  factory Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}

@JsonSerializable()
class Logprobs {
  final String token;
  final double logprob;
  final List<int> bytes;
  final List<TopLogprob> top_logprobs;

  Logprobs({
    required this.token,
    required this.logprob,
    required this.bytes,
    required this.top_logprobs,
  });

  factory Logprobs.fromJson(Map<String, dynamic> json) => _$LogprobsFromJson(json);

  Map<String, dynamic> toJson() => _$LogprobsToJson(this);
}

@JsonSerializable()
class TopLogprob {
  final String token;
  final double logprob;
  final List<int> bytes;

  TopLogprob({
    required this.token,
    required this.logprob,
    required this.bytes,
  });

  factory TopLogprob.fromJson(Map<String, dynamic> json) => _$TopLogprobFromJson(json);

  Map<String, dynamic> toJson() => _$TopLogprobToJson(this);
}

@JsonSerializable()
class ErrorInfo {
  final String code;
  final String message;

  ErrorInfo({
    required this.code,
    required this.message,
  });

  factory ErrorInfo.fromJson(Map<String, dynamic> json) => _$ErrorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ErrorInfoToJson(this);
}

@JsonSerializable()
class IncompleteDetails {
  final String reason;
  final String type;

  IncompleteDetails({
    required this.reason,
    required this.type,
  });

  factory IncompleteDetails.fromJson(Map<String, dynamic> json) => _$IncompleteDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$IncompleteDetailsToJson(this);
}

@JsonSerializable()
class ResponsesUsage {
  final int input_tokens;
  final int output_tokens;
  final int total_tokens;
  final UsageDetails input_tokens_details;
  final UsageDetails output_tokens_details;

  ResponsesUsage({
    required this.input_tokens,
    required this.output_tokens,
    required this.total_tokens,
    required this.input_tokens_details,
    required this.output_tokens_details,
  });

  factory ResponsesUsage.fromJson(Map<String, dynamic> json) => _$ResponsesUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ResponsesUsageToJson(this);
}

@JsonSerializable()
class UsageDetails {
  final int? cached_tokens;
  final int? text_tokens;
  final int? image_tokens;
  final int? audio_tokens;
  final int? reasoning_tokens;

  UsageDetails({
    this.cached_tokens,
    this.text_tokens,
    this.image_tokens,
    this.audio_tokens,
    this.reasoning_tokens,
  });

  factory UsageDetails.fromJson(Map<String, dynamic> json) => _$UsageDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$UsageDetailsToJson(this);
}