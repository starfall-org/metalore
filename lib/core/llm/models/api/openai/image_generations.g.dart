// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_generations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiImageGenerations _$OpenAiImageGenerationsFromJson(Map json) =>
    OpenAiImageGenerations(
      created: (json['created'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => ImageData.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$OpenAiImageGenerationsToJson(
        OpenAiImageGenerations instance) =>
    <String, dynamic>{
      'created': instance.created,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };

ImageData _$ImageDataFromJson(Map json) => ImageData(
      b64Json: json['b64_json'] as String?,
      url: json['url'] as String?,
      revisedPrompt: json['revised_prompt'] as String?,
    );

Map<String, dynamic> _$ImageDataToJson(ImageData instance) => <String, dynamic>{
      'b64_json': instance.b64Json,
      'url': instance.url,
      'revised_prompt': instance.revisedPrompt,
    };

ImageGenerationsRequest _$ImageGenerationsRequestFromJson(Map json) =>
    ImageGenerationsRequest(
      prompt: json['prompt'] as String,
      model: json['model'] as String,
      n: (json['n'] as num?)?.toInt(),
      size: json['size'] as String?,
      quality: json['quality'] as String?,
      responseFormat: json['response_format'] as String?,
      style: json['style'] as String?,
      user: json['user'] as String?,
    );

Map<String, dynamic> _$ImageGenerationsRequestToJson(
        ImageGenerationsRequest instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'model': instance.model,
      'n': instance.n,
      'size': instance.size,
      'quality': instance.quality,
      'response_format': instance.responseFormat,
      'style': instance.style,
      'user': instance.user,
    };
