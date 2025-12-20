enum ModelType {
  textGeneration,
  imageGeneration,
  audioGeneration,
  videoGeneration,
  embedding,
  rerank,
}

enum ModelIOType { text, video, image, audio }

class AIModel {
  final String name;
  final String displayName;
  final String? icon;
  final ModelType type;
  final List<ModelIOType> input;
  final List<ModelIOType> output;
  final ModelBuiltInTools builtInTools;
  final bool tool;
  final bool reasoning;
  final bool builtinWebSearch;
  final bool builtinWebFetch;
  final int? contextWindow;
  final int? parameters;

  AIModel({
    required this.name,
    required this.displayName,
    this.icon,
    this.type = ModelType.textGeneration,
    this.input = const [ModelIOType.text],
    this.output = const [ModelIOType.text],
    required this.builtInTools,
    this.tool = true,
    this.reasoning = false,
    this.builtinWebSearch = false,
    this.builtinWebFetch = false,
    this.contextWindow,
    this.parameters,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      if (icon != null) 'icon': icon,
      'type': type.name,
      'input': input.map((e) => e.name).toList(),
      'output': output.map((e) => e.name).toList(),
      'builtInTools': builtInTools.toJson(),
      'tool': tool,
      'reasoning': reasoning,
      'builtinWebSearch': builtinWebSearch,
      'builtinWebFetch': builtinWebFetch,
      'contextWindow': contextWindow,
      'parameters': parameters,
    };
  }

  factory AIModel.fromJson(Map<String, dynamic> json) {
    // Handle 'id' (OpenAI, Anthropic) and 'name' (Gemini, Ollama)
    final String name =
        json['id'] as String? ?? json['name'] as String? ?? 'unknown';
    final String displayName =
        json['displayName'] as String? ?? name.replaceAll('-', ' ');

    // Infer ModelType from name/id as providers don't return our internal enum values
    ModelType type = ModelType.textGeneration;
    final lowerName = name.toLowerCase();
    final bool defaultBuiltin = lowerName.contains('gemini');
    if (lowerName.contains('embed')) {
      type = ModelType.embedding;
    } else if (lowerName.contains('dall-e') ||
        lowerName.contains('gen-img') ||
        lowerName.contains('image')) {
      type = ModelType.imageGeneration;
    } else if (lowerName.contains('tts') ||
        lowerName.contains('audio') ||
        lowerName.contains('whisper')) {
      type = ModelType.audioGeneration;
    } else if (lowerName.contains('video') ||
        lowerName.contains('sora') ||
        lowerName.contains('veo')) {
      type = ModelType.videoGeneration;
    } else if (lowerName.contains('rerank')) {
      type = ModelType.rerank;
    }

    // Specific keys for context window from various providers:
    // Gemini: inputTokenLimit
    // Ollama/Local: context_window
    // Standard: contextWindow
    int? contextWindow =
        safeInt(json['contextWindow']) ??
        safeInt(json['inputTokenLimit']) ??
        safeInt(json['context_window']) ??
        safeInt(json['n_ctx']);

    // Reasoning detection: checks JSON first, then falls back to name heuristics
    bool reasoning = false;
    if (json['reasoning'] is bool) {
      reasoning = json['reasoning'];
    } else if (lowerName.contains('reason') ||
        lowerName.contains('think') ||
        lowerName.contains('chain')) {
      reasoning = true;
    }

    // Determine default IO based on type if not provided
    List<ModelIOType> defaultInput = [ModelIOType.text];
    List<ModelIOType> defaultOutput = [ModelIOType.text];

    switch (type) {
      case ModelType.imageGeneration:
        defaultOutput = [ModelIOType.text, ModelIOType.image];
        break;
      case ModelType.videoGeneration:
        defaultOutput = [ModelIOType.text, ModelIOType.video];
        break;
      case ModelType.audioGeneration:
        defaultOutput = [ModelIOType.text, ModelIOType.audio];
        break;
      case ModelType.textGeneration:
      default:
        // Check for multimodal capability
        if (lowerName.contains('vision') ||
            lowerName.contains('gpt-4o') ||
            lowerName.contains('gemini-1.5')) {
          defaultInput = [ModelIOType.text, ModelIOType.image];
        }
        break;
    }

    return AIModel(
      name: name,
      displayName: displayName,
      icon: json['icon'] as String?,
      type: type,
      input: json['input'] != null ? parseIOList(json['input']) : defaultInput,
      output: json['output'] != null
          ? parseIOList(json['output'])
          : defaultOutput,
      builtInTools: ModelBuiltInTools(
        urlContext: json['urlContext'] as bool,
        search: json['search'] as bool,
        codeExecution: json['codeExecution'] as bool,
      ),
      tool: json['tool'] is bool ? json['tool'] : true,
      reasoning: reasoning,
      builtinWebSearch: json['builtinWebSearch'] is bool
          ? json['builtinWebSearch']
          : defaultBuiltin,
      builtinWebFetch: json['builtinWebFetch'] is bool
          ? json['builtinWebFetch']
          : defaultBuiltin,
      contextWindow: contextWindow,
      parameters: safeInt(json['parameters']),
    );
  }
}

// Helper safely parse integers (handling int, double, string, null)
int? safeInt(dynamic val) {
  if (val is int) return val;
  if (val is double) return val.round();
  if (val is String) return int.tryParse(val);
  return null;
}

// Safe parsing for input/output lists
List<ModelIOType> parseIOList(dynamic list) {
  if (list is List) {
    return list
        .map(
          (e) => ModelIOType.values.firstWhere(
            (v) => v.name == e.toString(),
            orElse: () => ModelIOType.text,
          ),
        )
        .toList();
  }
  return [ModelIOType.text];
}

class ModelBuiltInTools {
  final bool urlContext;
  final bool search;
  final bool codeExecution;

  ModelBuiltInTools({
    required this.urlContext,
    required this.search,
    required this.codeExecution,
  });

  factory ModelBuiltInTools.fromJson(Map<String, dynamic> json) {
    return ModelBuiltInTools(
      urlContext: json['urlContext'] as bool,
      search: json['search'] as bool,
      codeExecution: json['codeExecution'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'urlContext': urlContext,
      'search': search,
      'codeExecution': codeExecution,
    };
  }
}
