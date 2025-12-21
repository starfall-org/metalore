import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ai/default_models.dart';
import 'shared_prefs_base_repository.dart';

/// Repository for managing default AI models configuration.
class DefaultModelsRepository
    extends SharedPreferencesBaseRepository<DefaultModels> {
  static const String _prefix = 'default_models';
  static const String _itemId = 'default_models_config';

  static DefaultModelsRepository? _instance;

  final ValueNotifier<DefaultModels> modelsNotifier =
      ValueNotifier<DefaultModels>(DefaultModels());

  DefaultModelsRepository(super.prefs) {
    _loadInitial();
  }

  static Future<DefaultModelsRepository> init() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    _instance = DefaultModelsRepository(prefs);
    return _instance!;
  }

  static DefaultModelsRepository get instance {
    if (_instance == null) {
      throw Exception(
        'DefaultModelsRepository not initialized. Call init() first.',
      );
    }
    return _instance!;
  }

  void _loadInitial() {
    final item = getItem(_itemId);
    if (item != null) {
      modelsNotifier.value = item;
    }
  }

  @override
  String get prefix => _prefix;

  @override
  String getItemId(DefaultModels item) => _itemId;

  @override
  Map<String, dynamic> serializeToFields(DefaultModels item) {
    return {
      'titleGenerationModel': item.titleGenerationModel?.toJson(),
      'chatSummarizationModel': item.chatSummarizationModel?.toJson(),
      'supportOCRModel': item.supportOCRModel?.toJson(),
      'embeddingModel': item.embeddingModel?.toJson(),
      'imageGenerationModel': item.imageGenerationModel?.toJson(),
      'chatModel': item.chatModel?.toJson(),
    };
  }

  @override
  DefaultModels deserializeFromFields(String id, Map<String, dynamic> fields) {
    return DefaultModels.fromJson(fields);
  }

  Future<void> updateModels(DefaultModels models) async {
    await saveItem(models);
    modelsNotifier.value = models;
  }

  DefaultModels get currentModels => modelsNotifier.value;
}
