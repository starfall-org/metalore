import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/storage/theme_repository.dart';
import 'core/storage/language_repository.dart';
import 'core/services/custom_asset_loader.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize ThemeRepository
  await ThemeRepository.init();
  
  // Initialize LanguageRepository
  await LanguageRepository.init();

  // On Android, prevent content from drawing under status/navigation bars
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: SystemUiOverlay.values,
  );

  // Lấy preferences ngôn ngữ đã lưu
  final languageRepo = LanguageRepository.instance;
  final preferences = languageRepo.currentPreferences;
  
  Locale selectedLocale;
  
  if (preferences.autoDetectLanguage || preferences.languageCode == 'auto') {
    // Tự động phát hiện ngôn ngữ thiết bị
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    selectedLocale = _getSupportedLocale(deviceLocale);
  } else {
    // Sử dụng ngôn ngữ đã lưu
    selectedLocale = _getLocaleFromPreferences(preferences);
  }
  
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
        Locale('zh', 'CN'),
        Locale('zh', 'TW'),
        Locale('ja'),
        Locale('fr'),
        Locale('de')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: false,
      assetLoader: CustomAssetLoader(),
      startLocale: selectedLocale,
      child: const AIGatewayApp(),
    ),
  );
}

// Hàm để xác định locale được hỗ trợ dựa trên ngôn ngữ thiết bị
Locale _getSupportedLocale(Locale deviceLocale) {
  // Danh sách các locale được hỗ trợ
  const supportedLocales = [
    Locale('en'),
    Locale('vi'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('ja'),
    Locale('fr'),
    Locale('de')
  ];
  
  // Kiểm tra xem locale của thiết bị có được hỗ trợ trực tiếp không
  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == deviceLocale.languageCode &&
        supportedLocale.countryCode == deviceLocale.countryCode) {
      return supportedLocale;
    }
  }
  
  // Kiểm tra xem ngôn ngữ có được hỗ trợ không (không quan tâm đến quốc gia)
  for (final supportedLocale in supportedLocales) {
    if (supportedLocale.languageCode == deviceLocale.languageCode) {
      // Đối với tiếng Trung, ưu tiên giản thể nếu không có quốc gia cụ thể
      if (deviceLocale.languageCode == 'zh') {
        return const Locale('zh', 'CN');
      }
      return supportedLocale;
    }
  }
  
  // Fallback sang tiếng Anh
  return const Locale('en');
}

// Hàm để lấy locale từ preferences
Locale _getLocaleFromPreferences(preferences) {
  if (preferences.countryCode != null) {
    return Locale(preferences.languageCode, preferences.countryCode);
  }
  return Locale(preferences.languageCode);
}
