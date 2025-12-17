import 'dart:ui';

class LanguagePreferences {
  final String languageCode;
  final String? countryCode;
  final bool autoDetectLanguage;

  const LanguagePreferences({
    required this.languageCode,
    this.countryCode,
    this.autoDetectLanguage = true,
  });

  factory LanguagePreferences.defaults() {
    return const LanguagePreferences(
      languageCode: 'auto',
      autoDetectLanguage: true,
    );
  }

  factory LanguagePreferences.fromJson(Map<String, dynamic> json) {
    return LanguagePreferences(
      languageCode: json['languageCode'] ?? 'auto',
      countryCode: json['countryCode'],
      autoDetectLanguage: json['autoDetectLanguage'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'countryCode': countryCode,
      'autoDetectLanguage': autoDetectLanguage,
    };
  }

  String toJsonString() {
    return toString();
  }

  factory LanguagePreferences.fromJsonString(String json) {
    // Simple JSON parsing for basic structure
    final parts = json.split(',');
    final Map<String, dynamic> data = {};
    
    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        final key = keyValue[0].trim().replaceAll('{', '').replaceAll('"', '');
        final value = keyValue[1].trim().replaceAll('}', '').replaceAll('"', '');
        data[key] = value;
      }
    }
    
    return LanguagePreferences.fromJson(data);
  }

  Locale? getLocale() {
    if (autoDetectLanguage || languageCode == 'auto') {
      return null; // Use auto-detection
    }
    
    if (countryCode != null) {
      return Locale(languageCode, countryCode);
    }
    return Locale(languageCode);
  }

  LanguagePreferences copyWith({
    String? languageCode,
    String? countryCode,
    bool? autoDetectLanguage,
  }) {
    return LanguagePreferences(
      languageCode: languageCode ?? this.languageCode,
      countryCode: countryCode ?? this.countryCode,
      autoDetectLanguage: autoDetectLanguage ?? this.autoDetectLanguage,
    );
  }

  @override
  String toString() {
    return '{"languageCode":"$languageCode","countryCode":"$countryCode","autoDetectLanguage":$autoDetectLanguage}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguagePreferences &&
        other.languageCode == languageCode &&
        other.countryCode == countryCode &&
        other.autoDetectLanguage == autoDetectLanguage;
  }

  @override
  int get hashCode {
    return languageCode.hashCode ^ countryCode.hashCode ^ autoDetectLanguage.hashCode;
  }
}