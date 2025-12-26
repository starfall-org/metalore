import 'package:flutter/material.dart';
import 'dart:async';

import '../../../core/data/ai_provider_store.dart';
import '../../../core/models/ai/provider.dart';
import '../../../core/models/ai/model.dart';

/// Controller responsible for provider and model selection
class ModelSelectionController extends ChangeNotifier {
  final ProviderRepository providerRepository;

  StreamSubscription? _providerSubscription;
  List<Provider> providers = [];
  final Map<String, bool> providerCollapsed = {}; // true = collapsed
  String? selectedProviderId;
  String? selectedModelName;

  ModelSelectionController({
    required this.providerRepository,
  }) {
    _providerSubscription = providerRepository.changes.listen((_) {
      refreshProviders();
    });
  }

  AIModel? get selectedAIModel {
    if (selectedProviderId == null || selectedModelName == null) return null;
    try {
      final provider = providers.firstWhere(
        (p) => p.id == selectedProviderId,
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
      providerCollapsed.putIfAbsent(p.id, () => false);
    }
    notifyListeners();
  }

  void setProviderCollapsed(String providerId, bool collapsed) {
    providerCollapsed[providerId] = collapsed;
    notifyListeners();
  }

  void selectModel(String providerId, String modelName) {
    selectedProviderId = providerId;
    selectedModelName = modelName;
    notifyListeners();
  }

  void loadSelectionFromSession({
    String? providerId,
    String? modelName,
  }) {
    if (providerId != null && modelName != null) {
      selectedProviderId = providerId;
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
