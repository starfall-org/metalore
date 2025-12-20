import 'package:hive_flutter/hive_flutter.dart';
import '../models/speech_service.dart';
import 'base_repository.dart';

class TTSRepository extends BaseRepository<SpeechService> {
  static const String _boxName = 'tts_profiles';

  TTSRepository(super.box);

  static Future<TTSRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    return TTSRepository(box);
  }

  @override
  String get boxName => _boxName;

  @override
  SpeechService deserializeItem(String json) => SpeechService.fromJsonString(json);

  @override
  String serializeItem(SpeechService item) => item.toJsonString();

  @override
  String getItemId(SpeechService item) => item.id;

  List<SpeechService> getProfiles() => getItems();

  Future<void> addProfile(SpeechService profile) => saveItem(profile);

  Future<void> deleteProfile(String id) => deleteItem(id);
}
