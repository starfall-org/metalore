import 'package:flutter/foundation.dart';
import '../../core/storage/base.dart';

import '../models/default_options.dart';


/// Repository for managing default AI models configuration.
class DefaultOptionsRepository
    extends SharedPreferencesBaseRepository<DefaultOptions> {
  static const String _prefix = 'default_models';
  static const String _itemId = 'default_models_config';

  static DefaultOptionsRepository? _instance;

  final ValueNotifier<DefaultOptions> modelsNotifier =
      ValueNotifier<DefaultOptions>(
        DefaultOptions(
          defaultModels: DefaultModels(),
          defaultProfileId: '',
        ),
      );

  DefaultOptionsRepository() {
    _loadInitial();
    // Auto-refresh notifier on any storage change (no restart needed)
    changes.listen((_) {
      final item = getItem(_itemId);
      if (item != null) {
        modelsNotifier.value = item;
      } else {
        modelsNotifier.value = DefaultOptions(
          defaultModels: DefaultModels(),
          defaultProfileId: '',
        );
      }
    });
  }

  static Future<DefaultOptionsRepository> init() async {
    if (_instance != null) return _instance!;
    _instance = DefaultOptionsRepository();
    return _instance!;
  }

  static DefaultOptionsRepository get instance {
    if (_instance == null) {
      throw Exception(
        'DefaultOptionsRepository not initialized. Call init() first.',
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
  String getItemId(DefaultOptions item) => _itemId;

  @override
  Map<String, dynamic> serializeToFields(DefaultOptions item) {
    // Store as a single nested document; base repository handles nested maps.
    return {
      'defaultModels': item.defaultModels.toJson(),
      'defaultProfileId': item.defaultProfileId,
    };
  }

  @override
  DefaultOptions deserializeFromFields(String id, Map<String, dynamic> fields) {
    return DefaultOptions.fromJson(fields);
  }

  Future<void> updateModels(DefaultOptions models) async {
    await saveItem(models);
    modelsNotifier.value = models;
  }

  DefaultOptions get currentModels => modelsNotifier.value;
}
