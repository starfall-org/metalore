class DefaultOptions {
  final DefaultModels defaultModels;
  final String defaultProfileId;

  const DefaultOptions({
    required this.defaultModels,
    required this.defaultProfileId,
  });

  factory DefaultOptions.fromJson(Map<String, dynamic> json) {
    return DefaultOptions(
      defaultModels: DefaultModels.fromJson(json['defaultModels']),
      defaultProfileId: json['defaultProfileId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultModels': defaultModels.toJson(),
      'defaultProfileId': defaultProfileId,
    };
  }
}

class DefaultModels {
  final DefaultModel? titleGenerationModel; // text generation model
  final DefaultModel? chatSummarizationModel; // text generation model
  final DefaultModel? translationModel; // text generation model
  final DefaultModel? supportOCRModel; // text generation (OCR) model
  final DefaultModel? embeddingModel; // embedding model
  final DefaultModel? imageGenerationModel; // image generation model
  final DefaultModel?
  chatModel; // text generation/image generation/video generation model
  final DefaultModel? audioGenerationModel; // audio generation model
  final DefaultModel? videoGenerationModel; // video generation model
  final DefaultModel? rerankModel; // rerank model

  DefaultModels({
    this.titleGenerationModel,
    this.chatSummarizationModel,
    this.translationModel,
    this.supportOCRModel,
    this.embeddingModel,
    this.imageGenerationModel,
    this.chatModel,
    this.audioGenerationModel,
    this.videoGenerationModel,
    this.rerankModel,
  });

  DefaultModels copyWith({
    DefaultModel? titleGenerationModel,
    DefaultModel? chatSummarizationModel,
    DefaultModel? translationModel,
    DefaultModel? supportOCRModel,
    DefaultModel? embeddingModel,
    DefaultModel? imageGenerationModel,
    DefaultModel? chatModel,
    DefaultModel? audioGenerationModel,
    DefaultModel? videoGenerationModel,
    DefaultModel? rerankModel,
  }) {
    return DefaultModels(
      titleGenerationModel: titleGenerationModel ?? this.titleGenerationModel,
      chatSummarizationModel:
          chatSummarizationModel ?? this.chatSummarizationModel,
      supportOCRModel: supportOCRModel ?? this.supportOCRModel,
      embeddingModel: embeddingModel ?? this.embeddingModel,
      imageGenerationModel: imageGenerationModel ?? this.imageGenerationModel,
      chatModel: chatModel ?? this.chatModel,
      audioGenerationModel: audioGenerationModel ?? this.audioGenerationModel,
      videoGenerationModel: videoGenerationModel ?? this.videoGenerationModel,
      rerankModel: rerankModel ?? this.rerankModel,
    );
  }

  factory DefaultModels.fromJson(Map<String, dynamic> json) {
    return DefaultModels(
      titleGenerationModel: json['titleGenerationModel'] != null
          ? DefaultModel.fromJson(json['titleGenerationModel'])
          : null,
      chatSummarizationModel: json['chatSummarizationModel'] != null
          ? DefaultModel.fromJson(json['chatSummarizationModel'])
          : null,
      translationModel: json['translationModel'] != null
          ? DefaultModel.fromJson(json['translationModel'])
          : null,
      supportOCRModel: json['supportOCRModel'] != null
          ? DefaultModel.fromJson(json['supportOCRModel'])
          : null,
      embeddingModel: json['embeddingModel'] != null
          ? DefaultModel.fromJson(json['embeddingModel'])
          : null,
      imageGenerationModel: json['imageGenerationModel'] != null
          ? DefaultModel.fromJson(json['imageGenerationModel'])
          : null,
      chatModel: json['chatModel'] != null
          ? DefaultModel.fromJson(json['chatModel'])
          : null,
      audioGenerationModel: json['audioGenerationModel'] != null
          ? DefaultModel.fromJson(json['audioGenerationModel'])
          : null,
      videoGenerationModel: json['videoGenerationModel'] != null
          ? DefaultModel.fromJson(json['videoGenerationModel'])
          : null,
      rerankModel: json['rerankModel'] != null
          ? DefaultModel.fromJson(json['rerankModel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titleGenerationModel': titleGenerationModel?.toJson(),
      'chatSummarizationModel': chatSummarizationModel?.toJson(),
      'translationModel': translationModel?.toJson(),
      'supportOCRModel': supportOCRModel?.toJson(),
      'embeddingModel': embeddingModel?.toJson(),
      'imageGenerationModel': imageGenerationModel?.toJson(),
      'chatModel': chatModel?.toJson(),
      'audioGenerationModel': audioGenerationModel?.toJson(),
      'videoGenerationModel': videoGenerationModel?.toJson(),
      'rerankModel': rerankModel?.toJson(),
    };
  }
}

class DefaultModel {
  final String modelName;
  final String providerName;

  DefaultModel({required this.modelName, required this.providerName});

  factory DefaultModel.fromJson(Map<String, dynamic> json) {
    return DefaultModel(
      modelName: json['modelName'] as String,
      providerName: json['providerName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'modelName': modelName, 'providerName': providerName};
  }
}
