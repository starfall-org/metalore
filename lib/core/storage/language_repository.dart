import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_preferences.dart';
import 'shared_prefs_base_repository.dart';

class LanguageRepository
    extends SharedPreferencesBaseRepository<LanguagePreferences> {
  static const String _prefix = 'language';

  // Expose a notifier for reactive UI updates
  final ValueNotifier<LanguagePreferences> languageNotifier = ValueNotifier(
    LanguagePreferences.defaults(),
  );

  LanguageRepository(super.prefs) {
    _loadInitialPreferences();
  }

  void _loadInitialPreferences() {
    final items = getItems();
    if (items.isNotEmpty) {
      languageNotifier.value = items.first;
    }
  }

  static LanguageRepository? _instance;

  static Future<LanguageRepository> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final prefs = await SharedPreferences.getInstance();
    _instance = LanguageRepository(prefs);
    return _instance!;
  }

  static LanguageRepository get instance {
    if (_instance == null) {
      throw Exception('LanguageRepository not initialized. Call init() first.');
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  // Single settings object, so ID is constant
  @override
  String getItemId(LanguagePreferences item) => 'language_settings';

  @override
  Map<String, dynamic> serializeToFields(LanguagePreferences item) {
    return {
      'languageCode': item.languageCode,
      'countryCode': item.countryCode,
      'autoDetectLanguage': item.autoDetectLanguage,
    };
  }

  @override
  LanguagePreferences deserializeFromFields(
    String id,
    Map<String, dynamic> fields,
  ) {
    return LanguagePreferences(
      languageCode: fields['languageCode'] as String? ?? 'auto',
      countryCode: fields['countryCode'] as String?,
      autoDetectLanguage: fields['autoDetectLanguage'] as bool? ?? true,
    );
  }

  Future<void> updatePreferences(LanguagePreferences preferences) async {
    try {
      // We only ever store one item for settings
      await saveItem(preferences);
      languageNotifier.value = preferences;
    } catch (e) {
      throw Exception('Failed to update language preferences: $e');
    }
  }

  LanguagePreferences get currentPreferences => languageNotifier.value;

  // Convenience methods
  Future<void> setLanguage(String languageCode, {String? countryCode}) async {
    try {
      final current = currentPreferences;
      final updated = current.copyWith(
        languageCode: languageCode,
        countryCode: countryCode,
        autoDetectLanguage: false,
      );
      await updatePreferences(updated);
    } catch (e) {
      throw Exception('Failed to set language: $e');
    }
  }

  Future<void> setAutoDetect(bool autoDetect) async {
    try {
      final current = currentPreferences;
      final updated = current.copyWith(autoDetectLanguage: autoDetect);
      await updatePreferences(updated);
    } catch (e) {
      throw Exception('Failed to set auto detect: $e');
    }
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(LanguagePreferences.defaults());
  }

  Locale getInitialLocale(Locale deviceLocale) {
    try {
      final preferences = currentPreferences;

      if (preferences.autoDetectLanguage ||
          preferences.languageCode == 'auto') {
        return _getSupportedLocale(deviceLocale);
      } else {
        return _getLocaleFromPreferences(preferences);
      }
    } catch (e) {
      debugPrint('Error loading language preferences: $e');
      return const Locale('en');
    }
  }

  Locale _getSupportedLocale(Locale deviceLocale) {
    try {
      if (deviceLocale.languageCode.isEmpty) {
        return const Locale('en');
      }

      const supportedLocales = [
        Locale('en'),
        Locale('vi'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ja'),
        Locale('fr'),
        Locale('de'),
      ];

      // Exact match language + country
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode &&
            supportedLocale.countryCode == deviceLocale.countryCode) {
          return supportedLocale;
        }
      }

      // Match language only
      for (final supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == deviceLocale.languageCode) {
          if (deviceLocale.languageCode == 'zh') {
            return const Locale('zh', 'CN');
          }
          return supportedLocale;
        }
      }

      return const Locale('en');
    } catch (e) {
      debugPrint('Error getting supported locale: $e');
      return const Locale('en');
    }
  }

  Locale _getLocaleFromPreferences(LanguagePreferences preferences) {
    try {
      if (preferences.languageCode.isEmpty) {
        return const Locale('en');
      }

      final supportedLanguages = ['en', 'vi', 'zh', 'ja', 'fr', 'de'];
      if (!supportedLanguages.contains(preferences.languageCode)) {
        return const Locale('en');
      }

      if (preferences.languageCode == 'zh') {
        if (preferences.countryCode != null &&
            (preferences.countryCode == 'CN' ||
                preferences.countryCode == 'TW')) {
          return Locale(preferences.languageCode, preferences.countryCode);
        } else {
          return const Locale('zh', 'CN'); // Default to simplified Chinese
        }
      }

      if (preferences.countryCode != null &&
          preferences.countryCode!.isNotEmpty) {
        return Locale(preferences.languageCode, preferences.countryCode);
      }

      return Locale(preferences.languageCode);
    } catch (e) {
      debugPrint('Error parsing locale from preferences: $e');
      return const Locale('en');
    }
  }
}
