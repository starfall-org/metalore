import 'package:flutter/material.dart';
import 'dart:async';

import '../../../../core/llm/storage/ai_provider_store.dart';
import '../../../../core/llm/models/ai_features/provider.dart';
import '../../../../core/llm/models/ai_model/base.dart';

/// Controller responsible for provider and model selection
class ModelSelectionController extends ChangeNotifier {
  final ProviderRepository providerRepository;

  StreamSubscription? _providerSubscription;
  List<Provider> providers = [];
  final Map<String, bool> providerCollapsed = {}; // true = collapsed
  String? selectedProviderName;
  String? selectedModelName;

  ModelSelectionController({
    required this.providerRepository,
  }) {
    _providerSubscription = providerRepository.changes.listen((_) {
      refreshProviders();
    });
  }

  AIModel? get selectedAIModel {
    if (selectedProviderName == null || selectedModelName == null) return null;
    try {
      final provider = providers.firstWhere(
        (p) => p.name == selectedProviderName,
      );
      return provider.models.firstWhere((m) => m.name == selectedModelName);
    } catch (e) {
      return null;
    }
  }

  Future<void> refreshProviders() async {
    providers = providerRepository.getProviders();
    // Initialize collapse map entries for unseen providers
    for (final p in providers) {
      providerCollapsed.putIfAbsent(p.name, () => false);
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerName, bool collapsed) {
    providerCollapsed[providerName] = collapsed;
    notifyListeners();
  }

  void selectModel(String providerName, String modelName) {
    selectedProviderName = providerName;
    selectedModelName = modelName;
    notifyListeners();
  }

  void loadSelectionFromSession({
    String? providerName,
    String? modelName,
  }) {
    if (providerName != null && modelName != null) {
      selectedProviderName = providerName;
      selectedModelName = modelName;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _providerSubscription?.cancel();
    super.dispose();
  }
}
