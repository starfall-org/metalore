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

class ThemeSettings {
  final ThemeMode themeMode;                 // actual brightness control used by MaterialApp
  final ThemeSelection selection;            // UI selection: system/light/dark/custom
  final int primaryColor;                    // ARGB int value
  final int secondaryColor;                  // ARGB int value
  final bool pureDark;                       // true => use pure black background for dark theme
  final bool materialYou;                    // true => use dynamic color (Material You) if supported
  final SecondaryBackgroundMode secondaryBackgroundMode; // controls dialog/drawer/sidebar surface

  const ThemeSettings({
    required this.themeMode,
    required this.selection,
    required this.primaryColor,
    required this.secondaryColor,
    required this.pureDark,
    required this.materialYou,
    required this.secondaryBackgroundMode,
  });

  factory ThemeSettings.defaults() {
    return ThemeSettings(
      themeMode: ThemeMode.system,
      selection: ThemeSelection.system,
      primaryColor: Colors.blue.value,
      secondaryColor: Colors.purple.value,
      pureDark: false,
      materialYou: false,
      secondaryBackgroundMode: SecondaryBackgroundMode.auto,
    );
  }

  ThemeSettings copyWith({
    ThemeMode? themeMode,
    ThemeSelection? selection,
    int? primaryColor,
    int? secondaryColor,
    bool? pureDark,
    bool? materialYou,
    SecondaryBackgroundMode? secondaryBackgroundMode,
  }) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      selection: selection ?? this.selection,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      pureDark: pureDark ?? this.pureDark,
      materialYou: materialYou ?? this.materialYou,
      secondaryBackgroundMode:
          secondaryBackgroundMode ?? this.secondaryBackgroundMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'selection': selection.index,
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'pureDark': pureDark,
      'materialYou': materialYou,
      'secondaryBackgroundMode': secondaryBackgroundMode.index,
    };
  }

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    try {
      final int? themeModeIndex = json['themeMode'] as int?;
      final int? selectionIndex = json['selection'] as int?;
      final int? primary = json['primaryColor'] as int?;
      final int? secondary = json['secondaryColor'] as int?;
      final bool pureDark = (json['pureDark'] as bool?) ?? false;
      final bool materialYou = (json['materialYou'] as bool?) ?? false;
      final int? sbmIndex = json['secondaryBackgroundMode'] as int?;

      // Backward compatibility with older schema using 'colorValue'
      final int? oldColor = json['colorValue'] as int?;

      final ThemeMode mode = (themeModeIndex != null &&
              themeModeIndex >= 0 &&
              themeModeIndex < ThemeMode.values.length)
          ? ThemeMode.values[themeModeIndex]
          : ThemeMode.system;

      final ThemeSelection sel = (selectionIndex != null &&
              selectionIndex >= 0 &&
              selectionIndex < ThemeSelection.values.length)
          ? ThemeSelection.values[selectionIndex]
          : ThemeSelection.system;

      final SecondaryBackgroundMode sbm =
          (sbmIndex != null &&
                  sbmIndex >= 0 &&
                  sbmIndex < SecondaryBackgroundMode.values.length)
              ? SecondaryBackgroundMode.values[sbmIndex]
              : SecondaryBackgroundMode.auto;

      return ThemeSettings(
        themeMode: mode,
        selection: sel,
        primaryColor: primary ?? oldColor ?? Colors.blue.value,
        secondaryColor: secondary ?? Colors.purple.value,
        pureDark: pureDark,
        materialYou: materialYou,
        secondaryBackgroundMode: sbm,
      );
    } catch (_) {
      return ThemeSettings.defaults();
    }
  }

  String toJsonString() => json.encode(toJson());

  factory ThemeSettings.fromJsonString(String jsonString) {
    try {
      if (jsonString.trim().isEmpty) return ThemeSettings.defaults();
      final dynamic data = json.decode(jsonString);
      if (data is Map<String, dynamic>) {
        return ThemeSettings.fromJson(data);
      }
      return ThemeSettings.defaults();
    } catch (_) {
      return ThemeSettings.defaults();
    }
  }
}