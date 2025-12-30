import 'package:meta/meta.dart';
import 'package:json_annotation/json_annotation.dart';

part 'audio_speech.g.dart';

/// Enum cho tham số response_format
@JsonEnum(valueField: 'value')
enum OpenAIAudioResponseFormat {
  mp3('mp3'),
  opus('opus'),
  aac('aac'),
  flac('flac'),
  wav('wav'),
  pcm('pcm');

  final String value;
  const OpenAIAudioResponseFormat(this.value);

  factory OpenAIAudioResponseFormat.fromJson(String json) => values.firstWhere(
    (e) => e.value == json,
    orElse: () => throw ArgumentError('Invalid response format: $json'),
  );

  String toJson() => value;
}

/// Request model cho API /v1/audio/speech
@immutable
@JsonSerializable()
class OpenAIAudioSpeechRequest {
  final String model;
  final String input;
  final String voice;
  final OpenAIAudioResponseFormat? responseFormat;
  final double? speed;

  const OpenAIAudioSpeechRequest({
    required this.model,
    required this.input,
    required this.voice,
    this.responseFormat,
    this.speed,
  });

  factory OpenAIAudioSpeechRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAIAudioSpeechRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIAudioSpeechRequestToJson(this);

  @override
  String toString() =>
      'OpenAIAudioSpeechRequest(model: $model, input: $input, voice: $voice)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIAudioSpeechRequest &&
        other.model == model &&
        other.input == input &&
        other.voice == voice &&
        other.responseFormat == responseFormat &&
        other.speed == speed;
  }

  @override
  int get hashCode => Object.hash(model, input, voice, responseFormat, speed);
}

/// Response model cho API /v1/audio/speech
@immutable
@JsonSerializable()
class OpenAIAudioSpeechResponse {
  @JsonKey(name: 'audio_content')
  final String audioContent;

  const OpenAIAudioSpeechResponse({required this.audioContent});

  factory OpenAIAudioSpeechResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIAudioSpeechResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIAudioSpeechResponseToJson(this);

  @override
  String toString() => 'OpenAIAudioSpeechResponse(audioContent: $audioContent)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIAudioSpeechResponse &&
        other.audioContent == audioContent;
  }

  @override
  int get hashCode => audioContent.hashCode;
}
