import 'package:flutter/material.dart';

import '../features/ai/ui/profiles_page.dart';
import '../features/ai/ui/providers_page.dart';
import '../features/ai/ui/speechsevices_page.dart';
import '../features/home/ui/chat_screen.dart';
import '../features/home/ui/home_screen.dart';
import '../features/settings/ui/about_page.dart';
import '../features/settings/ui/appearance_page.dart';
import '../features/settings/ui/preferences_page.dart';
import '../features/settings/ui/settings_page.dart';
import '../features/settings/ui/update_page.dart';
import '../features/settings/ui/userdata_page.dart';
import '../shared/translate/tl.dart';
import 'config/routes.dart';

/// Generate a route based on the route name.
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(builder: (_) => const HomePage());
    case AppRoutes.chat:
      return MaterialPageRoute(builder: (_) => const ChatPage());
    case AppRoutes.settings:
      return MaterialPageRoute(builder: (_) => const SettingsPage());
    case AppRoutes.appearance:
      return MaterialPageRoute(builder: (_) => const AppearancePage());
    case AppRoutes.preferences:
      return MaterialPageRoute(builder: (_) => const PreferencesPage());
    case AppRoutes.about:
      return MaterialPageRoute(builder: (_) => const AboutPage());
    case AppRoutes.update:
      return MaterialPageRoute(builder: (_) => const UpdatePage());
    case AppRoutes.userData:
      return MaterialPageRoute(builder: (_) => const DataControlsScreen());
    case AppRoutes.aiProviders:
      return MaterialPageRoute(builder: (_) => const AiProvidersPage());
    case AppRoutes.aiSpeechServices:
      return MaterialPageRoute(builder: (_) => const SpeechServicesPage());
    case AppRoutes.aiProfiles:
      return MaterialPageRoute(builder: (_) => const AIProfilesScreen());
    case AppRoutes.mcpServers:
      return MaterialPageRoute(builder: (_) => const HomePage());
    default:
      // Log the undefined route for debugging
      debugPrint(
        'Undefined route: ${settings.name}. Returning error screen instead of ChatPage.',
      );
      return MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text(tl('Not Found'))),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  ),
                  child: Text(tl('Go to Home')),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
