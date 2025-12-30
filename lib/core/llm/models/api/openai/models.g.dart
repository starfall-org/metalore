// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiModels _$OpenAiModelsFromJson(Map json) => OpenAiModels(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => BasicModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$OpenAiModelsToJson(OpenAiModels instance) =>
    <String, dynamic>{
      'object': instance.object,
      'data': instance.data.map((e) => e.toJson()).toList(),
    };
