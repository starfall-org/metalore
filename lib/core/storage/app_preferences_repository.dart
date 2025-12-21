import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import 'shared_prefs_base_repository.dart';

class AppPreferencesRepository
    extends SharedPreferencesBaseRepository<AppPreferences> {
  static const String _prefix = 'app_prefs';

  // Reactive notifier for UI/VM
  final ValueNotifier<AppPreferences> preferencesNotifier =
      ValueNotifier<AppPreferences>(AppPreferences.defaults());

  AppPreferencesRepository(super.prefs) {
    _loadInitial();
  }

  void _loadInitial() {
    final items = getItems();
    if (items.isNotEmpty) {
      preferencesNotifier.value = items.first;
    }
  }

  static AppPreferencesRepository? _instance;

  static Future<AppPreferencesRepository> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = AppPreferencesRepository(prefs);
    return _instance!;
  }

  static AppPreferencesRepository get instance {
    if (_instance == null) {
      throw Exception(
        'AppPreferencesRepository not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(AppPreferences item) => 'app_settings';

  @override
  Map<String, dynamic> serializeToFields(AppPreferences item) {
    return {
      'persistChatSelection': item.persistChatSelection,
      'hideStatusBar': item.hideStatusBar,
      'hideNavigationBar': item.hideNavigationBar,
      'debugMode': item.debugMode,
      'hasInitializedIcons': item.hasInitializedIcons,
      'vibrationSettings': {
        'enable': item.vibrationSettings.enable,
        'onHoldChatConversation': item.vibrationSettings.onHoldChatConversation,
        'onNewMessage': item.vibrationSettings.onNewMessage,
        'onGenerateToken': item.vibrationSettings.onGenerateToken,
        'onDeleteItem': item.vibrationSettings.onDeleteItem,
      },
    };
  }

  @override
  AppPreferences deserializeFromFields(String id, Map<String, dynamic> fields) {
    final vibrationSettingsMap =
        fields['vibrationSettings'] as Map<String, dynamic>? ?? {};

    return AppPreferences(
      persistChatSelection: fields['persistChatSelection'] as bool? ?? false,
      hideStatusBar: fields['hideStatusBar'] as bool? ?? false,
      hideNavigationBar: fields['hideNavigationBar'] as bool? ?? false,
      debugMode: fields['debugMode'] as bool? ?? false,
      hasInitializedIcons: fields['hasInitializedIcons'] as bool? ?? false,
      vibrationSettings: VibrationSettings(
        enable: vibrationSettingsMap['enable'] as bool? ?? false,
        onHoldChatConversation:
            vibrationSettingsMap['onHoldChatConversation'] as bool? ?? false,
        onNewMessage: vibrationSettingsMap['onNewMessage'] as bool? ?? false,
        onGenerateToken:
            vibrationSettingsMap['onGenerateToken'] as bool? ?? false,
        onDeleteItem: vibrationSettingsMap['onDeleteItem'] as bool? ?? false,
      ),
    );
  }

  Future<void> updatePreferences(AppPreferences preferences) async {
    try {
      await saveItem(preferences);
      preferencesNotifier.value = preferences;
    } catch (e) {
      throw Exception('Failed to update app preferences: $e');
    }
  }

  AppPreferences get currentPreferences => preferencesNotifier.value;

  // Convenience setters
  Future<void> setPersistChatSelection(bool persist) async {
    final current = currentPreferences;
    await updatePreferences(current.copyWith(persistChatSelection: persist));
  }

  Future<void> setPreferAgentSettings(bool preferAgent) async {
    // Deprecated in new model, but keeping for compatibility if needed or removing
    // final current = currentPreferences;
    // await updatePreferences(current.copyWith(preferAgentSettings: preferAgent));
  }

  Future<void> resetToDefaults() async {
    await updatePreferences(AppPreferences.defaults());
  }

  Future<void> setInitializedIcons(bool initialized) async {
    final current = currentPreferences;
    await updatePreferences(current.copyWith(hasInitializedIcons: initialized));
  }
}
