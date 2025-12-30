// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_completions.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiChatCompletionRequest _$OpenAiChatCompletionRequestFromJson(Map json) =>
    OpenAiChatCompletionRequest(
      model: json['model'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((e) =>
              RequestMessage.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      metadata: (json['metadata'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e as String),
      ),
      topLogprobs: (json['top_logprobs'] as num?)?.toInt(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      topP: (json['top_p'] as num?)?.toDouble(),
      user: json['user'] as String?,
      safetyIdentifier: json['safety_identifier'] as String?,
      promptCacheKey: json['prompt_cache_key'] as String?,
      serviceTier: json['service_tier'] as String?,
      modalities: (json['modalities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      verbosity: json['verbosity'] as String?,
      reasoningEffort: json['reasoning_effort'] as String?,
      maxCompletionTokens: (json['max_completion_tokens'] as num?)?.toInt(),
      frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
      presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
      webSearchOptions: json['web_search_options'] == null
          ? null
          : WebSearchOptions.fromJson(
              Map<String, dynamic>.from(json['web_search_options'] as Map)),
      responseFormat: json['response_format'] == null
          ? null
          : ResponseFormat.fromJson(
              Map<String, dynamic>.from(json['response_format'] as Map)),
      audio: json['audio'] == null
          ? null
          : AudioConfig.fromJson(
              Map<String, dynamic>.from(json['audio'] as Map)),
      store: json['store'] as bool?,
      stream: json['stream'] as bool?,
      stop: json['stop'] as String?,
      logitBias: (json['logit_bias'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      logprobs: json['logprobs'] as bool?,
      maxTokens: (json['max_tokens'] as num?)?.toInt(),
      n: (json['n'] as num?)?.toInt(),
      prediction: json['prediction'] == null
          ? null
          : Prediction.fromJson(
              Map<String, dynamic>.from(json['prediction'] as Map)),
      seed: (json['seed'] as num?)?.toInt(),
      streamOptions: json['stream_options'] == null
          ? null
          : StreamOptions.fromJson(
              Map<String, dynamic>.from(json['stream_options'] as Map)),
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => Tool.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      toolChoice: json['tool_choice'] as String?,
      parallelToolCalls: json['parallel_tool_calls'] as bool?,
      functionCall: json['function_call'] as String?,
      functions: (json['functions'] as List<dynamic>?)
          ?.map((e) =>
              FunctionDefinition.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$OpenAiChatCompletionRequestToJson(
        OpenAiChatCompletionRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'messages': instance.messages.map((e) => e.toJson()).toList(),
      'metadata': instance.metadata,
      'top_logprobs': instance.topLogprobs,
      'temperature': instance.temperature,
      'top_p': instance.topP,
      'user': instance.user,
      'safety_identifier': instance.safetyIdentifier,
      'prompt_cache_key': instance.promptCacheKey,
      'service_tier': instance.serviceTier,
      'modalities': instance.modalities,
      'verbosity': instance.verbosity,
      'reasoning_effort': instance.reasoningEffort,
      'max_completion_tokens': instance.maxCompletionTokens,
      'frequency_penalty': instance.frequencyPenalty,
      'presence_penalty': instance.presencePenalty,
      'web_search_options': instance.webSearchOptions?.toJson(),
      'response_format': instance.responseFormat?.toJson(),
      'audio': instance.audio?.toJson(),
      'store': instance.store,
      'stream': instance.stream,
      'stop': instance.stop,
      'logit_bias': instance.logitBias,
      'logprobs': instance.logprobs,
      'max_tokens': instance.maxTokens,
      'n': instance.n,
      'prediction': instance.prediction?.toJson(),
      'seed': instance.seed,
      'stream_options': instance.streamOptions?.toJson(),
      'tools': instance.tools?.map((e) => e.toJson()).toList(),
      'tool_choice': instance.toolChoice,
      'parallel_tool_calls': instance.parallelToolCalls,
      'function_call': instance.functionCall,
      'functions': instance.functions?.map((e) => e.toJson()).toList(),
    };

RequestMessage _$RequestMessageFromJson(Map json) => RequestMessage(
      role: json['role'] as String,
      content: json['content'],
      name: json['name'] as String?,
    );

Map<String, dynamic> _$RequestMessageToJson(RequestMessage instance) =>
    <String, dynamic>{
      'role': instance.role,
      'content': instance.content,
      'name': instance.name,
    };

WebSearchOptions _$WebSearchOptionsFromJson(Map json) => WebSearchOptions(
      userLocation: json['user_location'] == null
          ? null
          : UserLocation.fromJson(
              Map<String, dynamic>.from(json['user_location'] as Map)),
      searchContextSize: json['search_context_size'] as String?,
    );

Map<String, dynamic> _$WebSearchOptionsToJson(WebSearchOptions instance) =>
    <String, dynamic>{
      'user_location': instance.userLocation?.toJson(),
      'search_context_size': instance.searchContextSize,
    };

UserLocation _$UserLocationFromJson(Map json) => UserLocation(
      type: json['type'] as String,
      approximate: ApproximateLocation.fromJson(
          Map<String, dynamic>.from(json['approximate'] as Map)),
    );

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'approximate': instance.approximate.toJson(),
    };

ApproximateLocation _$ApproximateLocationFromJson(Map json) =>
    ApproximateLocation(
      country: json['country'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$ApproximateLocationToJson(
        ApproximateLocation instance) =>
    <String, dynamic>{
      'country': instance.country,
      'region': instance.region,
      'city': instance.city,
      'timezone': instance.timezone,
    };

ResponseFormat _$ResponseFormatFromJson(Map json) => ResponseFormat(
      type: json['type'] as String,
    );

Map<String, dynamic> _$ResponseFormatToJson(ResponseFormat instance) =>
    <String, dynamic>{
      'type': instance.type,
    };

AudioConfig _$AudioConfigFromJson(Map json) => AudioConfig(
      voice: json['voice'] as String,
      format: json['format'] as String,
    );

Map<String, dynamic> _$AudioConfigToJson(AudioConfig instance) =>
    <String, dynamic>{
      'voice': instance.voice,
      'format': instance.format,
    };

Prediction _$PredictionFromJson(Map json) => Prediction(
      type: json['type'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$PredictionToJson(Prediction instance) =>
    <String, dynamic>{
      'type': instance.type,
      'content': instance.content,
    };

StreamOptions _$StreamOptionsFromJson(Map json) => StreamOptions(
      includeUsage: json['include_usage'] as bool?,
      includeObfuscation: json['include_obfuscation'] as bool?,
    );

Map<String, dynamic> _$StreamOptionsToJson(StreamOptions instance) =>
    <String, dynamic>{
      'include_usage': instance.includeUsage,
      'include_obfuscation': instance.includeObfuscation,
    };

Tool _$ToolFromJson(Map json) => Tool(
      type: json['type'] as String,
      function: FunctionDefinition.fromJson(
          Map<String, dynamic>.from(json['function'] as Map)),
    );

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
      'type': instance.type,
      'function': instance.function.toJson(),
    };

FunctionDefinition _$FunctionDefinitionFromJson(Map json) => FunctionDefinition(
      description: json['description'] as String?,
      name: json['name'] as String,
      parameters: (json['parameters'] as Map?)?.map(
        (k, e) => MapEntry(k as String, e),
      ),
      strict: json['strict'] as bool?,
    );

Map<String, dynamic> _$FunctionDefinitionToJson(FunctionDefinition instance) =>
    <String, dynamic>{
      'description': instance.description,
      'name': instance.name,
      'parameters': instance.parameters,
      'strict': instance.strict,
    };

OpenAiChatCompletion _$OpenAiChatCompletionFromJson(Map json) =>
    OpenAiChatCompletion(
      id: json['id'] as String?,
      object: json['object'] as String?,
      created: (json['created'] as num?)?.toInt(),
      model: json['model'] as String?,
      choices: (json['choices'] as List<dynamic>?)
          ?.map((e) => Choice.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      usage: json['usage'] == null
          ? null
          : ChatCompletionUsage.fromJson(
              Map<String, dynamic>.from(json['usage'] as Map)),
      systemFingerprint: json['system_fingerprint'] as String?,
      serviceTier: json['service_tier'] as String?,
    );

Map<String, dynamic> _$OpenAiChatCompletionToJson(
        OpenAiChatCompletion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'choices': instance.choices?.map((e) => e.toJson()).toList(),
      'usage': instance.usage?.toJson(),
      'system_fingerprint': instance.systemFingerprint,
      'service_tier': instance.serviceTier,
    };

Choice _$ChoiceFromJson(Map json) => Choice(
      index: (json['index'] as num?)?.toInt(),
      message: json['message'] == null
          ? null
          : Message.fromJson(Map<String, dynamic>.from(json['message'] as Map)),
      delta: json['delta'] == null
          ? null
          : Delta.fromJson(Map<String, dynamic>.from(json['delta'] as Map)),
      finishReason: json['finish_reason'] as String?,
      logprobs: json['logprobs'] == null
          ? null
          : Logprobs.fromJson(
              Map<String, dynamic>.from(json['logprobs'] as Map)),
    );

Map<String, dynamic> _$ChoiceToJson(Choice instance) => <String, dynamic>{
      'index': instance.index,
      'message': instance.message?.toJson(),
      'delta': instance.delta?.toJson(),
      'finish_reason': instance.finishReason,
      'logprobs': instance.logprobs?.toJson(),
    };

Message _$MessageFromJson(Map json) => Message(
      content: json['content'] as String?,
      refusal: json['refusal'] as String?,
      role: json['role'] as String,
      functionCall: json['function_call'] == null
          ? null
          : FunctionCall.fromJson(
              Map<String, dynamic>.from(json['function_call'] as Map)),
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      annotations: (json['annotations'] as List<dynamic>?)
          ?.map((e) => Annotation.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      audio: json['audio'] == null
          ? null
          : Audio.fromJson(Map<String, dynamic>.from(json['audio'] as Map)),
      reasoningContent: json['reasoning_content'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'content': instance.content,
      'refusal': instance.refusal,
      'role': instance.role,
      'function_call': instance.functionCall?.toJson(),
      'tool_calls': instance.toolCalls?.map((e) => e.toJson()).toList(),
      'annotations': instance.annotations?.map((e) => e.toJson()).toList(),
      'audio': instance.audio?.toJson(),
      'reasoning_content': instance.reasoningContent,
    };

Delta _$DeltaFromJson(Map json) => Delta(
      content: json['content'] as String?,
      role: json['role'] as String?,
      refusal: json['refusal'] as String?,
      functionCall: json['function_call'] == null
          ? null
          : FunctionCall.fromJson(
              Map<String, dynamic>.from(json['function_call'] as Map)),
      toolCalls: (json['tool_calls'] as List<dynamic>?)
          ?.map((e) => ToolCall.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$DeltaToJson(Delta instance) => <String, dynamic>{
      'content': instance.content,
      'role': instance.role,
      'refusal': instance.refusal,
      'function_call': instance.functionCall?.toJson(),
      'tool_calls': instance.toolCalls?.map((e) => e.toJson()).toList(),
    };

ToolCall _$ToolCallFromJson(Map json) => ToolCall(
      id: json['id'] as String?,
      type: json['type'] as String?,
      function: json['function'] == null
          ? null
          : FunctionCall.fromJson(
              Map<String, dynamic>.from(json['function'] as Map)),
    );

Map<String, dynamic> _$ToolCallToJson(ToolCall instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'function': instance.function?.toJson(),
    };

FunctionCall _$FunctionCallFromJson(Map json) => FunctionCall(
      name: json['name'] as String?,
      arguments: json['arguments'] as String?,
    );

Map<String, dynamic> _$FunctionCallToJson(FunctionCall instance) =>
    <String, dynamic>{
      'name': instance.name,
      'arguments': instance.arguments,
    };

Annotation _$AnnotationFromJson(Map json) => Annotation(
      type: json['type'] as String?,
      urlCitation: json['url_citation'] == null
          ? null
          : UrlCitation.fromJson(
              Map<String, dynamic>.from(json['url_citation'] as Map)),
    );

Map<String, dynamic> _$AnnotationToJson(Annotation instance) =>
    <String, dynamic>{
      'type': instance.type,
      'url_citation': instance.urlCitation?.toJson(),
    };

UrlCitation _$UrlCitationFromJson(Map json) => UrlCitation(
      endIndex: (json['end_index'] as num?)?.toInt(),
      startIndex: (json['start_index'] as num?)?.toInt(),
      url: json['url'] as String?,
      title: json['title'] as String?,
    );

Map<String, dynamic> _$UrlCitationToJson(UrlCitation instance) =>
    <String, dynamic>{
      'end_index': instance.endIndex,
      'start_index': instance.startIndex,
      'url': instance.url,
      'title': instance.title,
    };

Audio _$AudioFromJson(Map json) => Audio(
      id: json['id'] as String?,
      expiresAt: (json['expires_at'] as num?)?.toInt(),
      data: json['data'] as String?,
      transcript: json['transcript'] as String?,
    );

Map<String, dynamic> _$AudioToJson(Audio instance) => <String, dynamic>{
      'id': instance.id,
      'expires_at': instance.expiresAt,
      'data': instance.data,
      'transcript': instance.transcript,
    };

Logprobs _$LogprobsFromJson(Map json) => Logprobs(
      content: (json['content'] as List<dynamic>?)
          ?.map((e) => Token.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      refusal: (json['refusal'] as List<dynamic>?)
          ?.map((e) => Token.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$LogprobsToJson(Logprobs instance) => <String, dynamic>{
      'content': instance.content?.map((e) => e.toJson()).toList(),
      'refusal': instance.refusal?.map((e) => e.toJson()).toList(),
    };

Token _$TokenFromJson(Map json) => Token(
      token: json['token'] as String?,
      logprob: (json['logprob'] as num?)?.toDouble(),
      bytes: (json['bytes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      topLogprobs: (json['top_logprobs'] as List<dynamic>?)
          ?.map((e) => TopLogprob.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$TokenToJson(Token instance) => <String, dynamic>{
      'token': instance.token,
      'logprob': instance.logprob,
      'bytes': instance.bytes,
      'top_logprobs': instance.topLogprobs?.map((e) => e.toJson()).toList(),
    };

TopLogprob _$TopLogprobFromJson(Map json) => TopLogprob(
      token: json['token'] as String?,
      logprob: (json['logprob'] as num?)?.toDouble(),
      bytes: (json['bytes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$TopLogprobToJson(TopLogprob instance) =>
    <String, dynamic>{
      'token': instance.token,
      'logprob': instance.logprob,
      'bytes': instance.bytes,
    };

ChatCompletionUsage _$ChatCompletionUsageFromJson(Map json) =>
    ChatCompletionUsage(
      promptTokens: (json['prompt_tokens'] as num?)?.toInt(),
      completionTokens: (json['completion_tokens'] as num?)?.toInt(),
      totalTokens: (json['total_tokens'] as num?)?.toInt(),
      completionTokensDetails: json['completion_tokens_details'] == null
          ? null
          : CompletionTokenDetails.fromJson(Map<String, dynamic>.from(
              json['completion_tokens_details'] as Map)),
      promptTokensDetails: json['prompt_tokens_details'] == null
          ? null
          : PromptTokenDetails.fromJson(
              Map<String, dynamic>.from(json['prompt_tokens_details'] as Map)),
    );

Map<String, dynamic> _$ChatCompletionUsageToJson(
        ChatCompletionUsage instance) =>
    <String, dynamic>{
      'prompt_tokens': instance.promptTokens,
      'completion_tokens': instance.completionTokens,
      'total_tokens': instance.totalTokens,
      'completion_tokens_details': instance.completionTokensDetails?.toJson(),
      'prompt_tokens_details': instance.promptTokensDetails?.toJson(),
    };

PromptTokenDetails _$PromptTokenDetailsFromJson(Map json) => PromptTokenDetails(
      cachedTokens: (json['cached_tokens'] as num?)?.toInt(),
      audioTokens: (json['audio_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PromptTokenDetailsToJson(PromptTokenDetails instance) =>
    <String, dynamic>{
      'cached_tokens': instance.cachedTokens,
      'audio_tokens': instance.audioTokens,
    };

CompletionTokenDetails _$CompletionTokenDetailsFromJson(Map json) =>
    CompletionTokenDetails(
      reasoningTokens: (json['reasoning_tokens'] as num?)?.toInt(),
      audioTokens: (json['audio_tokens'] as num?)?.toInt(),
      acceptedPredictionTokens:
          (json['accepted_prediction_tokens'] as num?)?.toInt(),
      rejectedPredictionTokens:
          (json['rejected_prediction_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CompletionTokenDetailsToJson(
        CompletionTokenDetails instance) =>
    <String, dynamic>{
      'reasoning_tokens': instance.reasoningTokens,
      'audio_tokens': instance.audioTokens,
      'accepted_prediction_tokens': instance.acceptedPredictionTokens,
      'rejected_prediction_tokens': instance.rejectedPredictionTokens,
    };

Custom _$CustomFromJson(Map json) => Custom(
      input: json['input'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CustomToJson(Custom instance) => <String, dynamic>{
      'input': instance.input,
      'name': instance.name,
    };
