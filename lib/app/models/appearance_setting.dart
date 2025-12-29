import 'dart:convert';
import 'package:flutter/material.dart';

//// Theme selection high-level mode for UI:
/// - system, light, dark mirror ThemeMode
/// - custom enables custom primary/secondary color presets & pickers
enum ThemeSelection { system, light, dark, custom }

/// Secondary background behavior for surfaces like dialogs/drawers/sidebars
/// - off: same as main background; add high-contrast border
/// - auto: slight delta from main background for subtle separation
/// - on: tinted from secondary color for stronger separation
enum SecondaryBackgroundMode { off, auto, on }

class AppearanceSetting {
  ThemeMode themeMode; // actual brightness control used by MaterialApp
  final ThemeSelection selection; // UI selection: system/light/dark/custom
  final int primaryColor; // ARGB int value
  final int secondaryColor; // ARGB int value
  final int backgroundColor; // ARGB int value
  final int surfaceColor; // ARGB int value
  final int textColor; // ARGB int value
  final int textHintColor; // ARGB int value
  final bool superDarkMode; // true => use pure black background for dark theme
  final bool dynamicColor; // true => use dynamic color  if supported
  final String fontFamily;
  final int chatFontSize;
  final int appFontSize;
  final bool enableAnimation;

  AppearanceSetting({
    this.themeMode = ThemeMode.system,
    required this.selection,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.textHintColor,
    required this.superDarkMode,
    required this.dynamicColor,
    required this.fontFamily,
    required this.chatFontSize,
    required this.appFontSize,
    required this.enableAnimation,
  });

  factory AppearanceSetting.defaults({ThemeMode? themeMode}) {
    // Xác định màu mặc định dựa trên theme mode
    final bool isDark = themeMode == ThemeMode.dark;
    
    return AppearanceSetting(
      themeMode: themeMode ?? ThemeMode.system,
      selection: ThemeSelection.system,
      primaryColor: Colors.blue.toARGB32(),
      secondaryColor: Colors.purple.toARGB32(),
      backgroundColor: isDark ? Colors.black.toARGB32() : Colors.white.toARGB32(),
      surfaceColor: isDark ? Colors.black.toARGB32() : Colors.white.toARGB32(),
      textColor: isDark ? Colors.white.toARGB32() : Colors.black.toARGB32(),
      textHintColor: isDark ? Colors.white.toARGB32() : Colors.black.toARGB32(),
      superDarkMode: false,
      dynamicColor: false,
      fontFamily: 'Roboto',
      chatFontSize: 16,
      appFontSize: 16,
      enableAnimation: true,
    );
  }

  AppearanceSetting copyWith({
    ThemeMode? themeMode,
    ThemeSelection? selection,
    int? primaryColor,
    int? secondaryColor,
    int? backgroundColor,
    int? surfaceColor,
    int? textColor,
    int? textHintColor,
    bool? superDarkMode,
    bool? dynamicColor,
    String? fontFamily,
    int? chatFontSize,
    int? appFontSize,
    bool? enableAnimation,
    SecondaryBackgroundMode? secondaryBackgroundMode,
  }) {
    return AppearanceSetting(
      themeMode: themeMode ?? this.themeMode,
      selection: selection ?? this.selection,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      surfaceColor: surfaceColor ?? this.surfaceColor,
      textColor: textColor ?? this.textColor,
      textHintColor: textHintColor ?? this.textHintColor,
      superDarkMode: superDarkMode ?? this.superDarkMode,
      dynamicColor: dynamicColor ?? this.dynamicColor,
      fontFamily: fontFamily ?? this.fontFamily,
      chatFontSize: chatFontSize ?? this.chatFontSize,
      appFontSize: appFontSize ?? this.appFontSize,
      enableAnimation: enableAnimation ?? this.enableAnimation,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'selection': selection.index,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'backgroundColor': backgroundColor,
      'surfaceColor': surfaceColor,
      'textColor': textColor,
      'textHintColor': textHintColor,
      'superDarkMode': superDarkMode,
      'dynamicColor': dynamicColor,
      'fontFamily': fontFamily,
      'chatFontSize': chatFontSize,
      'appFontSize': appFontSize,
      'enableAnimation': enableAnimation,
    };
  }

  factory AppearanceSetting.fromJson(Map<String, dynamic> json) {
    try {
      final int? themeModeIndex = json['themeMode'] as int?;
      final int? selectionIndex = json['selection'] as int?;
      final int? primary = json['primaryColor'] as int?;
      final int? secondary = json['secondaryColor'] as int?;
      final int? backgroundColor = json['backgroundColor'] as int?;
      final int? surfaceColor = json['surfaceColor'] as int?;
      final int? textColor = json['textColor'] as int?;
      final int? textHintColor = json['textHintColor'] as int?;
      final bool superDarkMode = (json['superDarkMode'] as bool?) ?? false;
      final bool dynamicColor = (json['dynamicColor'] as bool?) ?? false;
      final String? fontFamily = json['fontFamily'] as String?;
      final int? chatFontSize = json['chatFontSize'] as int?;
      final int? appFontSize = json['appFontSize'] as int?;
      final int? oldFontSize = json['fontSize'] as int?;
      final bool enableAnimation = (json['enableAnimation'] as bool?) ?? false;

      // Backward compatibility with older schema using 'colorValue'
      final int? oldColor = json['colorValue'] as int?;

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

      // Xác định màu mặc định dựa trên theme mode
      final bool isDark = mode == ThemeMode.dark;

      return AppearanceSetting(
        themeMode: mode,
        selection: sel,
        primaryColor: primary ?? oldColor ?? Colors.blue.toARGB32(),
        secondaryColor: secondary ?? Colors.purple.toARGB32(),
        backgroundColor: backgroundColor ?? (isDark ? Colors.black.toARGB32() : Colors.white.toARGB32()),
        surfaceColor: surfaceColor ?? (isDark ? Colors.black.toARGB32() : Colors.white.toARGB32()),
        textColor: textColor ?? (isDark ? Colors.white.toARGB32() : Colors.black.toARGB32()),
        textHintColor: textHintColor ?? (isDark ? Colors.white.toARGB32() : Colors.black.toARGB32()),
        superDarkMode: superDarkMode,
        dynamicColor: dynamicColor,
        fontFamily: fontFamily ?? 'Roboto',
        chatFontSize: chatFontSize ?? oldFontSize ?? 16,
        appFontSize: appFontSize ?? oldFontSize ?? 16,
        enableAnimation: enableAnimation,
      );
    } catch (_) {
      return AppearanceSetting.defaults(themeMode: ThemeMode.system);
    }
  }

  String toJsonString() => json.encode(toJson());

  factory AppearanceSetting.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) return AppearanceSetting.defaults(themeMode: ThemeMode.system);
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return AppearanceSetting.fromJson(data);
      }
      return AppearanceSetting.defaults(themeMode: ThemeMode.system);
    } catch (_) {
      return AppearanceSetting.defaults(themeMode: ThemeMode.system);
    }
  }
}
