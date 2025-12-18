import 'package:flutter/material.dart';
import '../../../core/storage/theme_repository.dart';
import '../../../core/models/theme.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_card.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  final ThemeRepository _repository = ThemeRepository.instance;
  late ThemeSettings _settings;

  // 5 preset colors (must include black and white)
  static const List<Color> _presets = <Color>[
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.red,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _settings = _repository.currentTheme;
  }

  Future<void> _updateSelection(ThemeSelection selection) async {
    // Keep themeMode in sync for non-custom selections
    ThemeMode mode = _settings.themeMode;
    switch (selection) {
      case ThemeSelection.system:
        mode = ThemeMode.system;
        break;
      case ThemeSelection.light:
        mode = ThemeMode.light;
        break;
      case ThemeSelection.dark:
        mode = ThemeMode.dark;
        break;
      case ThemeSelection.custom:
        // keep current themeMode; custom only affects colors
        mode = _settings.themeMode;
        break;
    }
    final newSettings = _settings.copyWith(selection: selection, themeMode: mode);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _updatePrimary(int colorValue) async {
    final newSettings = _settings.copyWith(primaryColor: colorValue);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _updateSecondary(int colorValue) async {
    final newSettings = _settings.copyWith(secondaryColor: colorValue);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _togglePureDark(bool value) async {
    final newSettings = _settings.copyWith(pureDark: value);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _toggleMaterialYou(bool value) async {
    final newSettings = _settings.copyWith(materialYou: value);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  Future<void> _updateSecondaryBackgroundMode(SecondaryBackgroundMode mode) async {
    final newSettings = _settings.copyWith(secondaryBackgroundMode: mode);
    await _repository.updateSettings(newSettings);
    setState(() => _settings = newSettings);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _settings.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.appearance'.tr()),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme selection: system, light, dark, custom
          SettingsSectionHeader('settings.theme_mode'.tr()),
          const SizedBox(height: 8),
          _buildThemeSelection(),

          const SizedBox(height: 24),

          // Pure dark toggle (applies only to dark theme)
          SettingsSectionHeader('settings.pure_dark'.tr()),
          SettingsCard(
            child: SwitchListTile(
              title: Text('settings.pure_dark'.tr()),
              subtitle: Text('settings.pure_dark_desc'.tr()),
              value: _settings.pureDark,
              onChanged: (val) => _togglePureDark(val),
            ),
          ),

          const SizedBox(height: 24),

          // Material You toggle
          SettingsSectionHeader('settings.material_you'.tr()),
          DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
              final bool supported = (lightDynamic != null || darkDynamic != null);
              return SettingsCard(
                child: SwitchListTile(
                  title: Text('settings.material_you'.tr()),
                  subtitle: Text(
                    supported
                        ? 'settings.material_you_desc'.tr()
                        : 'settings.material_you_unsupported'.tr(),
                  ),
                  value: _settings.materialYou,
                  onChanged: supported ? (val) => _toggleMaterialYou(val) : null,
                ),
              );
            },
          ),

          // Secondary Background Mode (only when Material You is OFF)
          if (!_settings.materialYou) ...[
            const SizedBox(height: 12),
            SettingsSectionHeader('settings.secondary_background'.tr()),
            SettingsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                    child: Text(
                      'settings.secondary_background_desc'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  RadioGroup<SecondaryBackgroundMode>(
                    groupValue: _settings.secondaryBackgroundMode,
                    onChanged: (val) {
                      if (val != null) _updateSecondaryBackgroundMode(val);
                    },
                    child: Column(
                      children: [
                        RadioListTile<SecondaryBackgroundMode>(
                          title: Text('settings.secondary_bg_on'.tr()),
                          value: SecondaryBackgroundMode.on,
                        ),
                        RadioListTile<SecondaryBackgroundMode>(
                          title: Text('settings.secondary_bg_auto'.tr()),
                          subtitle: Text('settings.secondary_bg_auto_desc'.tr()),
                          value: SecondaryBackgroundMode.auto,
                        ),
                        RadioListTile<SecondaryBackgroundMode>(
                          title: Text('settings.secondary_bg_off'.tr()),
                          subtitle: Text('settings.secondary_bg_off_desc'.tr()),
                          value: SecondaryBackgroundMode.off,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 4),
                          child: Text(
                            'settings.secondary_bg_border_rule'.tr(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Color customization is only visible in Custom mode and disabled when Material You is enabled
          if (!_settings.materialYou && _settings.selection == ThemeSelection.custom) ...[
            SettingsSectionHeader('settings.primary_color'.tr()),
            const SizedBox(height: 8),
            _buildColorSelector(
              current: Color(_settings.primaryColor),
              onSelect: (c) => _updatePrimary(c.value),
            ),

            const SizedBox(height: 16),

            SettingsSectionHeader('settings.secondary_color'.tr()),
            const SizedBox(height: 8),
            _buildColorSelector(
              current: Color(_settings.secondaryColor),
              onSelect: (c) => _updateSecondary(c.value),
            ),
            const SizedBox(height: 24),
          ],

          _buildPreview(isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildThemeSelection() {
    return SettingsCard(
      child: RadioGroup<ThemeSelection>(
        groupValue: _settings.selection,
        onChanged: (val) {
          if (val != null) _updateSelection(val);
        },
        child: Column(
          children: [
            RadioListTile<ThemeSelection>(
              title: Text('settings.system_default'.tr()),
              value: ThemeSelection.system,
            ),
            RadioListTile<ThemeSelection>(
              title: Text('settings.light'.tr()),
              value: ThemeSelection.light,
            ),
            RadioListTile<ThemeSelection>(
              title: Text('settings.dark'.tr()),
              value: ThemeSelection.dark,
            ),
            RadioListTile<ThemeSelection>(
              title: Text('settings.custom'.tr()),
              value: ThemeSelection.custom,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector({
    required Color current,
    required ValueChanged<Color> onSelect,
  }) {
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Presets
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'settings.color_presets'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presets.map((color) {
              final isSelected = current.value == color.value;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 2,
                          )
                        : null,
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() < 0.5
                              ? Colors.white
                              : Colors.black,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // Custom picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.color_lens_outlined),
              label: Text('settings.custom_color'.tr()),
              onPressed: () async {
                final picked = await _pickColor(context, initial: current);
                if (picked != null) {
                  onSelect(picked);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Color?> _pickColor(BuildContext context, {required Color initial}) async {
    Color temp = initial;
    int r = temp.red;
    int g = temp.green;
    int b = temp.blue;

    return showDialog<Color>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('settings.custom_color'.tr()),
          content: StatefulBuilder(
            builder: (context, setState) {
              temp = Color.fromARGB(255, r, g, b);
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 44,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: temp,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _sliderRow('R', r, (v) => setState(() => r = v)),
                  _sliderRow('G', g, (v) => setState(() => g = v)),
                  _sliderRow('B', b, (v) => setState(() => b = v)),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: Text('settings.close'.tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(Color.fromARGB(255, r, g, b)),
              child: Text('settings.update'.tr()),
            ),
          ],
        );
      },
    );
  }

  Widget _sliderRow(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        SizedBox(width: 20, child: Text(label)),
        Expanded(
          child: Slider(
            min: 0,
            max: 255,
            value: value.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            value.toString(),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPreview({required bool isDark}) {
    final primary = Color(_settings.primaryColor);
    final secondary = Color(_settings.secondaryColor);

    return SettingsCard(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary,
                  child: Icon(
                    Icons.person,
                    color: primary.computeLuminance() < 0.5
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings.preview_title'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      'settings.preview_subtitle'.tr(),
                      style: TextStyle(
                        color: isDark ? Colors.grey : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: primary.computeLuminance() < 0.5
                    ? Colors.white
                    : Colors.black,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              child: Text('settings.preview_button'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
