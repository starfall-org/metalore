import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'core/app_routes.dart';
import 'core/config/routes.dart';
import 'core/config/theme.dart';
import 'shared/prefs/appearance.dart';

class AIGatewayApp extends StatelessWidget {
  const AIGatewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = AppearanceSp.instance;

    return ValueListenableBuilder(
      valueListenable: repository.themeNotifier,
      builder: (context, settings, _) {
        return DynamicColorBuilder(
          builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
            final bool useDynamic = settings.dynamicColor;

            final ColorScheme lightScheme = (useDynamic && lightDynamic != null)
                ? lightDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.light,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                    surface: Color(settings.surfaceColor),
                  );

            final ColorScheme darkScheme = (useDynamic && darkDynamic != null)
                ? darkDynamic.harmonized()
                : ColorScheme.fromSeed(
                    seedColor: Color(settings.primaryColor),
                    brightness: Brightness.dark,
                  ).copyWith(
                    secondary: Color(settings.secondaryColor),
                    surface: Color(settings.surfaceColor),
                  );

            // Apply custom text colors only if they match the current brightness
            // Otherwise use ColorScheme defaults (fixes black text in dark mode when using system theme)
            final Color customTextColor = Color(settings.textColor);
            final Color customTextHintColor = Color(settings.textHintColor);

            final bool useCustomTextColor = (lightScheme.brightness == Brightness.light && customTextColor.computeLuminance() < 0.5) ||
                                             (lightScheme.brightness == Brightness.dark && customTextColor.computeLuminance() > 0.5);

            final TextTheme customLightTextTheme = TextTheme(
              bodyLarge: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              bodyMedium: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              bodySmall: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              labelLarge: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              labelMedium: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              labelSmall: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              titleLarge: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              titleMedium: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              titleSmall: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              headlineLarge: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              headlineMedium: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              headlineSmall: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              displayLarge: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              displayMedium: useCustomTextColor ? TextStyle(color: customTextColor) : null,
              displaySmall: useCustomTextColor ? TextStyle(color: customTextColor) : null,
            );

            final bool useCustomTextColorDark = (darkScheme.brightness == Brightness.light && customTextColor.computeLuminance() < 0.5) ||
                                                (darkScheme.brightness == Brightness.dark && customTextColor.computeLuminance() > 0.5);

            final TextTheme customDarkTextTheme = TextTheme(
              bodyLarge: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              bodyMedium: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              bodySmall: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              labelLarge: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              labelMedium: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              labelSmall: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              titleLarge: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              titleMedium: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              titleSmall: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              headlineLarge: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              headlineMedium: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              headlineSmall: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              displayLarge: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              displayMedium: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
              displaySmall: useCustomTextColorDark ? TextStyle(color: customTextColor) : null,
            );

            // Update hint colors in the theme
            final InputDecorationTheme lightInputDecorationTheme =
                InputDecorationTheme(
                  hintStyle: useCustomTextColor ? TextStyle(color: customTextHintColor) : null,
                );

            final InputDecorationTheme darkInputDecorationTheme =
                InputDecorationTheme(
                  hintStyle: useCustomTextColorDark ? TextStyle(color: customTextHintColor) : null,
                );

            // Main background colors
            final Color lightMainBg = Colors.white;
            final Color darkMainBg = settings.superDarkMode
                ? Colors.black
                : const Color(0xFF121212);

            // Utilities for secondary background calculation

            Color deriveSecondaryBg(
              Brightness br,
              ColorScheme scheme,
              Color mainBg,
            ) {
              return scheme.secondaryContainer;
            }

            // Light palette surfaces
            final Color lightSecondaryBg = deriveSecondaryBg(
              Brightness.light,
              lightScheme,
              lightMainBg,
            );
            final BorderSide lightBorderSide = BorderSide(
              color: customTextHintColor,
              width: 1,
            );

            // Dark palette surfaces
            final Color darkSecondaryBg = deriveSecondaryBg(
              Brightness.dark,
              darkScheme,
              darkMainBg,
            );
            final BorderSide darkBorderSide = BorderSide(
              color: customTextHintColor,
              width: 1,
            );

            return MaterialApp(
              title: 'AI Gateway',
              debugShowCheckedModeBanner: false,
              themeMode: settings.themeMode,
              theme: ThemeData(
                colorScheme: lightScheme,
                useMaterial3: true,
                textTheme: customLightTextTheme,
                inputDecorationTheme: lightInputDecorationTheme,
                scaffoldBackgroundColor: lightMainBg,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: lightSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: lightBorderSide,
                  ),
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: lightSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: lightBorderSide,
                  ),
                ),
                navigationDrawerTheme: NavigationDrawerThemeData(
                  backgroundColor: lightSecondaryBg,
                ),
                extensions: <ThemeExtension<dynamic>>[
                  SecondarySurface(
                    backgroundColor: lightSecondaryBg,
                    borderSide: lightBorderSide,
                  ),
                ],
              ),
              darkTheme: ThemeData(
                colorScheme: darkScheme,
                useMaterial3: true,
                textTheme: customDarkTextTheme,
                inputDecorationTheme: darkInputDecorationTheme,
                scaffoldBackgroundColor: darkMainBg,
                appBarTheme: const AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarDividerColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.light,
                  ),
                ),
                dialogTheme: DialogThemeData(
                  backgroundColor: darkSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: darkBorderSide,
                  ),
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: darkSecondaryBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: darkBorderSide,
                  ),
                ),
                navigationDrawerTheme: NavigationDrawerThemeData(
                  backgroundColor: darkSecondaryBg,
                ),
                extensions: <ThemeExtension<dynamic>>[
                  SecondarySurface(
                    backgroundColor: darkSecondaryBg,
                    borderSide: darkBorderSide,
                  ),
                ],
              ),
              onGenerateRoute: generateRoute,
              initialRoute: AppRoutes.chat,
            );
          },
        );
      },
    );
  }
}
