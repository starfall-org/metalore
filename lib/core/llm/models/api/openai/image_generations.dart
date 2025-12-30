import 'package:json_annotation/json_annotation.dart';

part 'image_generations.g.dart';

@JsonSerializable()
class OpenAiImageGenerations {
  final int created;
  final List<ImageData> data;

  OpenAiImageGenerations({
    required this.created,
    required this.data,
  });

  factory OpenAiImageGenerations.fromJson(Map<String, dynamic> json) =>
      _$OpenAiImageGenerationsFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAiImageGenerationsToJson(this);
}

@JsonSerializable()
class ImageData {
  final String? b64Json;
  final String? url;
  final String? revisedPrompt;

  ImageData({
    this.b64Json,
    this.url,
    this.revisedPrompt,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) =>
      _$ImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$ImageDataToJson(this);
}

@JsonSerializable()
class ImageGenerationsRequest {
  final String prompt;
  final String model;
  final int? n;
  final String? size;
  final String? quality;
  final String? responseFormat;
  final String? style;
  final String? user;

  ImageGenerationsRequest({
    required this.prompt,
    required this.model,
    this.n,
    this.size,
    this.quality,
    this.responseFormat,
    this.style,
    this.user,
  });

  factory ImageGenerationsRequest.fromJson(Map<String, dynamic> json) =>
      _$ImageGenerationsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ImageGenerationsRequestToJson(this);
}