import 'dart:typed_data';
import '../../models/tts_profile.dart';
import '../../storage/provider_repository.dart';
import 'i_tts_service.dart';
import 'openai_tts.dart';
import 'gemini_tts.dart';
import 'system_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  factory TTSService() => _instance;

  TTSService._internal();

  // Cache services if needed, or instantiate on demand
  final SystemTTS _systemTTS = SystemTTS();

  // Dependency injection for accessing API keys
  // Ideally passed in or retrieved via Service Locator
  // For now, we will fetch from repository inside the logic or pass keys in.
  // Requires access to ProviderRepository to look up keys.

  Future<Uint8List> synthesize(TTSProfile profile, String text, String model) async {
    final service = await _getServiceForProfile(profile);
    
    // Look up API Key and Base URL if using a provider
    String? apiKey;
    String? baseUrl;
    if (profile.type == TTSServiceType.provider && profile.provider != null) {
      final providerRepo = await ProviderRepository.init(); 
      final provider = providerRepo.getItem(profile.provider!);
      apiKey = provider?.apiKey;
      baseUrl = provider?.baseUrl;
    }

    return service.synthesize(
      text, 
      model,
      profile.voiceId, 
      profile.settings,
      apiKey: apiKey,
      baseApiUrl: baseUrl,
    );
  }

  /// Determines the correct service implementation based on the profile
  Future<ITTSService> _getServiceForProfile(TTSProfile profile) async {
    if (profile.type == TTSServiceType.system) {
      return _systemTTS;
    }

    // For provider based services, we need to check the provider type and get API Key
    final providerName = profile.provider;
    if (providerName == null) {
      return _systemTTS; // Fallback
    }

    // Note: accessing Repository directly here creates tight coupling.
    // Ideally use DI. For simplicity in this session, we get the instance.
    // ProviderRepository.init() is async.
    final providerRepo = await ProviderRepository.init();
    final provider = providerRepo.getItem(providerName);

    if (provider == null) {
      throw Exception("Provider '$providerName' not found for TTS Profile");
    }

    // Heuristic or Explicit Type check to decide implementation
    
    if (providerName.toLowerCase().contains('openai')) {
      return OpenAITTS();
    } 
    else if (providerName.toLowerCase().contains('gemini') || providerName.toLowerCase().contains('google')) {
      return GeminiTTS();
    }
    
    // Default fallback
    return _systemTTS;
  }
}
