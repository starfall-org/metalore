import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/storage/language_repository.dart';
import '../widgets/settings_section_header.dart';
import '../widgets/settings_tile.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  late LanguageRepository _languageRepository;
  bool _autoDetectLanguage = true;
  String _selectedLanguage = 'auto';

  final List<Map<String, dynamic>> _supportedLanguages = [
    {'code': 'auto', 'name': 'preferences.auto_detect', 'flag': '🌐'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'zh_CN', 'name': '简体中文', 'flag': '🇨🇳'},
    {'code': 'zh_TW', 'name': '繁體中文', 'flag': '🇹🇼'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
  ];

  @override
  void initState() {
    super.initState();
    _languageRepository = LanguageRepository.instance;
    _loadPreferences();
  }

  void _loadPreferences() {
    final preferences = _languageRepository.currentPreferences;
    setState(() {
      _autoDetectLanguage = preferences.autoDetectLanguage;
      _selectedLanguage = preferences.languageCode;
    });
  }

  Future<void> _toggleAutoDetect(bool value) async {
    setState(() {
      _autoDetectLanguage = value;
      if (value) {
        _selectedLanguage = 'auto';
      }
    });

    await _languageRepository.setAutoDetect(value);
    
    if (value) {
      // Restart app to apply auto-detection
      _restartApp();
    }
  }

  Future<void> _selectLanguage(String languageCode) async {
    setState(() {
      _selectedLanguage = languageCode;
      _autoDetectLanguage = false;
    });

    String? countryCode;
    if (languageCode.contains('_')) {
      final parts = languageCode.split('_');
      countryCode = parts[1];
      languageCode = parts[0];
    }

    await _languageRepository.setLanguage(languageCode, countryCode: countryCode);
    
    // Restart app to apply language change
    _restartApp();
  }

  void _restartApp() {
    // Use SystemChannels to trigger app restart
    // Note: This will completely close the app, not just restart
    // Consider using a different approach if this causes navigation issues
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'settings.preferences'.tr(),
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: ListView(
        children: [
          SettingsSectionHeader('Language'),
          SettingsTile(
            icon: Icons.language_outlined,
            title: 'preferences.auto_detect_language'.tr(),
            trailing: Switch(
              value: _autoDetectLanguage,
              onChanged: _toggleAutoDetect,
            ),
          ),
          if (!_autoDetectLanguage) ...[
            SettingsSectionHeader('preferences.select_language'.tr()),
            ..._supportedLanguages.where((lang) => lang['code'] != 'auto').map((language) {
              final isSelected = _selectedLanguage == language['code'];
              return SettingsTile(
                icon: Icons.language,
                title: '${language['flag']} ${language['name']}',
                trailing: isSelected
                    ? Icon(
                        Icons.check,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => _selectLanguage(language['code']),
              );
            }).toList(),
          ],
          SettingsSectionHeader('preferences.about'.tr()),
          SettingsTile(
            icon: Icons.info_outline,
            title: 'preferences.current_language'.tr(),
            trailing: Text(
              _getCurrentLanguageName(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentLanguageName() {
    if (_autoDetectLanguage) {
      return 'preferences.auto_detect'.tr();
    }
    
    final selected = _supportedLanguages.firstWhere(
      (lang) => lang['code'] == _selectedLanguage,
      orElse: () => _supportedLanguages.first,
    );
    
    return selected['name'];
  }
}