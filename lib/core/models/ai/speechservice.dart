import 'dart:convert';

enum ServiceType { system, provider }

class SpeechService {
  final String id;
  final String name;
  final String? icon;

  final TextToSpeech tts;
  final SpeechToText stt;

  const SpeechService({
    required this.id,
    required this.name,
    this.icon,
    required this.tts,
    required this.stt,
  });

  Map<String, dynamic> toJson() {
    return {'tts': tts.toJson(), 'stt': stt.toJson()};
  }

  factory SpeechService.fromJson(Map<String, dynamic> json) {
    return SpeechService(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      tts: TextToSpeech.fromJson(json['tts']),
      stt: SpeechToText.fromJson(json['stt']),
    );
  }
}

class TextToSpeech {
  final String id;
  final String icon;
  final String name;
  final ServiceType type;
  final String? provider;
  final String? model;
  final String? voiceId;
  final Map<dynamic, dynamic> settings;

  const TextToSpeech({
    required this.id,
    required this.icon,
    required this.name,
    required this.type,
    this.provider,
    this.model,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'type': type.name,
      'provider': provider,
      'model': model,
      'voiceId': voiceId,
      'settings': settings,
    };
  }

  factory TextToSpeech.fromJson(Map<String, dynamic> json) {
    return TextToSpeech(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      type: ServiceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ServiceType.system,
      ),
      provider: json['provider'] as String?,
      model: json['model'] as String?,
      voiceId: json['voiceId'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  String toJsonString() => json.encode(toJson());

  factory TextToSpeech.fromJsonString(String jsonString) {
    if (jsonString.trim().isEmpty) {
      throw FormatException("Empty JSON string");
    }
    return TextToSpeech.fromJson(json.decode(jsonString));
  }
}

class SpeechToText {
  final String id;
  final String icon;
  final String name;
  final ServiceType type;
  final String? provider;
  final String? model;
  final String? voiceId;
  final Map<dynamic, dynamic> settings;

  const SpeechToText({
    required this.id,
    required this.icon,
    required this.name,
    required this.type,
    this.provider,
    this.model,
    this.voiceId,
    this.settings = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'icon': icon,
      'name': name,
      'type': type.name,
      'provider': provider,
      'model': model,
      'voiceId': voiceId,
      'settings': settings,
    };
  }

  factory SpeechToText.fromJson(Map<String, dynamic> json) {
    return SpeechToText(
      id: json['id'] as String,
      icon: json['icon'] as String,
      name: json['name'] as String,
      type: ServiceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ServiceType.system,
      ),
      provider: json['provider'] as String?,
      model: json['model'] as String?,
      voiceId: json['voiceId'] as String?,
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }
}
