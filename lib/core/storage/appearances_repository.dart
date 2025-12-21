import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/appearances.dart';
import 'shared_prefs_base_repository.dart';

class AppearancesRepository
    extends SharedPreferencesBaseRepository<Appearances> {
  static const String _prefix = 'appearance';

  // Expose a notifier for valid reactive UI updates
  final ValueNotifier<Appearances> themeNotifier = ValueNotifier(
    Appearances.defaults(),
  );

  AppearancesRepository(super.prefs) {
    _loadInitialTheme();
  }

  void _loadInitialTheme() {
    final items = getItems();
    if (items.isNotEmpty) {
      themeNotifier.value = items.first;
    }
  }

  static AppearancesRepository? _instance;

  static Future<AppearancesRepository> init() async {
    if (_instance != null) {
      return _instance!;
    }
    final prefs = await SharedPreferences.getInstance();
    _instance = AppearancesRepository(prefs);
    return _instance!;
  }

  static AppearancesRepository get instance {
    if (_instance == null) {
      throw Exception(
        'AppearancesRepository not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  @override
  String get prefix => _prefix;

  // Single settings object, so ID is constant
  @override
  String getItemId(Appearances item) => 'settings';

  @override
  Map<String, dynamic> serializeToFields(Appearances item) {
    return {
      'themeMode': item.themeMode.index,
      'selection': item.selection.index,
      'primaryColor': item.primaryColor,
      'secondaryColor': item.secondaryColor,
      'backgroundColor': item.backgroundColor,
      'surfaceColor': item.surfaceColor,
      'textColor': item.textColor,
      'darkmodeTextColor': item.darkmodeTextColor,
      'textHintColor': item.textHintColor,
      'darkmodeTextHintColor': item.darkmodeTextHintColor,
      'superDarkMode': item.superDarkMode,
      'dynamicColor': item.dynamicColor,
      'fontFamily': item.fontFamily,
      'chatFontSize': item.chatFontSize,
      'appFontSize': item.appFontSize,
      'enableAnimation': item.enableAnimation,
      'secondaryBackgroundMode': item.secondaryBackgroundMode.index,
    };
  }

  @override
  Appearances deserializeFromFields(String id, Map<String, dynamic> fields) {
    final int? themeModeIndex = fields['themeMode'] as int?;
    final int? selectionIndex = fields['selection'] as int?;
    final int? secondaryBgIndex = fields['secondaryBackgroundMode'] as int?;

    final ThemeMode mode =
        (themeModeIndex != null &&
            themeModeIndex >= 0 &&
            themeModeIndex < ThemeMode.values.length)
        ? ThemeMode.values[themeModeIndex]
        : ThemeMode.system;

    final ThemeSelection sel =
        (selectionIndex != null &&
            selectionIndex >= 0 &&
            selectionIndex < ThemeSelection.values.length)
        ? ThemeSelection.values[selectionIndex]
        : ThemeSelection.system;

    final SecondaryBackgroundMode secBg =
        (secondaryBgIndex != null &&
            secondaryBgIndex >= 0 &&
            secondaryBgIndex < SecondaryBackgroundMode.values.length)
        ? SecondaryBackgroundMode.values[secondaryBgIndex]
        : SecondaryBackgroundMode.off;

    return Appearances(
      themeMode: mode,
      selection: sel,
      primaryColor: fields['primaryColor'] as int? ?? Colors.blue.toARGB32(),
      secondaryColor:
          fields['secondaryColor'] as int? ?? Colors.purple.toARGB32(),
      backgroundColor:
          fields['backgroundColor'] as int? ?? Colors.white.toARGB32(),
      surfaceColor: fields['surfaceColor'] as int? ?? Colors.white.toARGB32(),
      textColor: fields['textColor'] as int? ?? Colors.black.toARGB32(),
      darkmodeTextColor:
          fields['darkmodeTextColor'] as int? ?? Colors.white.toARGB32(),
      textHintColor: fields['textHintColor'] as int? ?? Colors.black.toARGB32(),
      darkmodeTextHintColor:
          fields['darkmodeTextHintColor'] as int? ?? Colors.white.toARGB32(),
      superDarkMode: fields['superDarkMode'] as bool? ?? false,
      dynamicColor: fields['dynamicColor'] as bool? ?? false,
      fontFamily: fields['fontFamily'] as String? ?? 'Roboto',
      chatFontSize: fields['chatFontSize'] as int? ?? 16,
      appFontSize: fields['appFontSize'] as int? ?? 16,
      enableAnimation: fields['enableAnimation'] as bool? ?? true,
      secondaryBackgroundMode: secBg,
    );
  }

  Future<void> updateSettings(Appearances settings) async {
    // We only ever store one item for settings
    await saveItem(settings);
    themeNotifier.value = settings;
  }

  Appearances get currentTheme => themeNotifier.value;
}
