// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAiResponsesRequest _$OpenAiResponsesRequestFromJson(Map json) =>
    OpenAiResponsesRequest(
      model: json['model'] as String,
      input: (json['input'] as List<dynamic>)
          .map((e) => InputItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      tools: (json['tools'] as List?)
          ?.map((e) => Tool.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      toolChoice: json['tool_choice'],
      temperature: (json['temperature'] as num?)?.toDouble(),
      maxOutputTokens: (json['max_output_tokens'] as num?)?.toInt(),
      stream: json['stream'] as bool?,
      reasoning: json['reasoning'] as Map<String, dynamic>?,
      previousResponseIds: (json['previous_response_ids'] as List?)
          ?.map((e) => e as String)
          .toList(),
      includeRawUserInput: json['include_raw_user_input'] as bool?,
      user: json['user'] as String?,
    );

Map<String, dynamic> _$OpenAiResponsesRequestToJson(
        OpenAiResponsesRequest instance) =>
    <String, dynamic>{
      'model': instance.model,
      'input': instance.input.map((e) => e.toJson()).toList(),
      if (instance.tools != null) 'tools': instance.tools!.map((e) => e.toJson()).toList(),
      if (instance.toolChoice != null) 'tool_choice': instance.toolChoice,
      if (instance.temperature != null) 'temperature': instance.temperature,
      if (instance.maxOutputTokens != null)
        'max_output_tokens': instance.maxOutputTokens,
      if (instance.stream != null) 'stream': instance.stream,
      if (instance.reasoning != null) 'reasoning': instance.reasoning,
      if (instance.previousResponseIds != null)
        'previous_response_ids': instance.previousResponseIds,
      if (instance.includeRawUserInput != null)
        'include_raw_user_input': instance.includeRawUserInput,
      if (instance.user != null) 'user': instance.user,
    };

InputItem _$InputItemFromJson(Map json) => InputItem(
      type: json['type'] as String,
      text: json['text'] as String?,
      imageUrl: json['image_url'] != null
          ? InputImageUrl.fromJson(
              Map<String, dynamic>.from(json['image_url'] as Map))
          : null,
      imageDetail: json['image_detail'] != null
          ? InputImageDetail.fromJson(
              Map<String, dynamic>.from(json['image_detail'] as Map))
          : null,
    );

Map<String, dynamic> _$InputItemToJson(InputItem instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.text != null) 'text': instance.text,
      if (instance.imageUrl != null) 'image_url': instance.imageUrl!.toJson(),
      if (instance.imageDetail != null)
        'image_detail': instance.imageDetail!.toJson(),
    };

InputImageUrl _$InputImageUrlFromJson(Map json) => InputImageUrl(
      url: json['url'] as String,
      detail: json['detail'] as String?,
    );

Map<String, dynamic> _$InputImageUrlToJson(InputImageUrl instance) =>
    <String, dynamic>{
      'url': instance.url,
      if (instance.detail != null) 'detail': instance.detail,
    };

InputImageDetail _$InputImageDetailFromJson(Map json) => InputImageDetail(
      type: json['type'] as String,
      x: (json['x'] as num?)?.toInt(),
      y: (json['y'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InputImageDetailToJson(InputImageDetail instance) =>
    <String, dynamic>{
      'type': instance.type,
      if (instance.x != null) 'x': instance.x,
      if (instance.y != null) 'y': instance.y,
      if (instance.width != null) 'width': instance.width,
      if (instance.height != null) 'height': instance.height,
    };

Tool _$ToolFromJson(Map json) => Tool(
      type: json['type'] as String,
      function: ToolFunction.fromJson(
          Map<String, dynamic>.from(json['function'] as Map)),
    );

Map<String, dynamic> _$ToolToJson(Tool instance) => <String, dynamic>{
      'type': instance.type,
      'function': instance.function.toJson(),
    };

ToolFunction _$ToolFunctionFromJson(Map json) => ToolFunction(
      name: json['name'] as String,
      description: json['description'] as String?,
      parameters: json['parameters'] as Map<String, dynamic>?,
      strict: json['strict'] as bool?,
    );

Map<String, dynamic> _$ToolFunctionToJson(ToolFunction instance) =>
    <String, dynamic>{
      'name': instance.name,
      if (instance.description != null) 'description': instance.description,
      if (instance.parameters != null) 'parameters': instance.parameters,
      if (instance.strict != null) 'strict': instance.strict,
    };

OpenAiResponses _$OpenAiResponsesFromJson(Map json) => OpenAiResponses(
      id: json['id'] as String,
      object: json['object'] as String,
      created: (json['created'] as num).toInt(),
      model: json['model'] as String,
      status: json['status'] as String,
      output: (json['output'] as List<dynamic>)
          .map((e) => ResponseItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      usage: ResponsesUsage.fromJson(
          Map<String, dynamic>.from(json['usage'] as Map)),
      incompleteDetails: json['incomplete_details'] as String?,
      error: json['error'] != null
          ? ErrorInfo.fromJson(Map<String, dynamic>.from(json['error'] as Map))
          : null,
    );

Map<String, dynamic> _$OpenAiResponsesToJson(OpenAiResponses instance) =>
    <String, dynamic>{
      'id': instance.id,
      'object': instance.object,
      'created': instance.created,
      'model': instance.model,
      'status': instance.status,
      'output': instance.output.map((e) => e.toJson()).toList(),
      'usage': instance.usage.toJson(),
      if (instance.incompleteDetails != null)
        'incomplete_details': instance.incompleteDetails,
      if (instance.error != null) 'error': instance.error!.toJson(),
    };

ResponseItem _$ResponseItemFromJson(Map json) => ResponseItem(
      id: json['id'] as String,
      type: json['type'] as String,
      text: json['text'] as String?,
      refusal: json['refusal'] != null
          ? Refusal.fromJson(Map<String, dynamic>.from(json['refusal'] as Map))
          : null,
      functionCall: json['function_call'] != null
          ? FunctionCallItem.fromJson(
              Map<String, dynamic>.from(json['function_call'] as Map))
          : null,
      functionCallOutput: json['function_call_output'] != null
          ? FunctionCallOutput.fromJson(
              Map<String, dynamic>.from(json['function_call_output'] as Map))
          : null,
      index: (json['index'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResponseItemToJson(ResponseItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      if (instance.text != null) 'text': instance.text,
      if (instance.refusal != null) 'refusal': instance.refusal!.toJson(),
      if (instance.functionCall != null)
        'function_call': instance.functionCall!.toJson(),
      if (instance.functionCallOutput != null)
        'function_call_output': instance.functionCallOutput!.toJson(),
      if (instance.index != null) 'index': instance.index,
    };

Refusal _$RefusalFromJson(Map json) => Refusal(
      text: json['text'] as String,
    );

Map<String, dynamic> _$RefusalToJson(Refusal instance) => <String, dynamic>{
      'text': instance.text,
    };

FunctionCallItem _$FunctionCallItemFromJson(Map json) => FunctionCallItem(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      arguments: json['arguments'] as String?,
    );

Map<String, dynamic> _$FunctionCallItemToJson(FunctionCallItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      if (instance.arguments != null) 'arguments': instance.arguments,
    };

FunctionCallOutput _$FunctionCallOutputFromJson(Map json) => FunctionCallOutput(
      callId: json['call_id'] as String,
      type: json['type'] as String,
      output: json['output'] as String,
    );

Map<String, dynamic> _$FunctionCallOutputToJson(
        FunctionCallOutput instance) =>
    <String, dynamic>{
      'call_id': instance.callId,
      'type': instance.type,
      'output': instance.output,
    };

ResponsesUsage _$ResponsesUsageFromJson(Map json) => ResponsesUsage(
      inputTokens: (json['input_tokens'] as num).toInt(),
      outputTokens: (json['output_tokens'] as num).toInt(),
      totalTokens: (json['total_tokens'] as num).toInt(),
      inputTokensDetails: (json['input_tokens_details'] as num?)?.toInt(),
      outputTokensDetails: (json['output_tokens_details'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResponsesUsageToJson(ResponsesUsage instance) =>
    <String, dynamic>{
      'input_tokens': instance.inputTokens,
      'output_tokens': instance.outputTokens,
      'total_tokens': instance.totalTokens,
      if (instance.inputTokensDetails != null)
        'input_tokens_details': instance.inputTokensDetails,
      if (instance.outputTokensDetails != null)
        'output_tokens_details': instance.outputTokensDetails,
    };

ErrorInfo _$ErrorInfoFromJson(Map json) => ErrorInfo(
      type: json['type'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$ErrorInfoToJson(ErrorInfo instance) => <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
    };

StreamingResponseEvent _$StreamingResponseEventFromJson(Map json) =>
    StreamingResponseEvent(
      id: json['id'] as String?,
      type: json['type'] as String?,
      delta: json['delta'] as String?,
      item: json['item'] != null
          ? ResponseItem.fromJson(Map<String, dynamic>.from(json['item'] as Map))
          : null,
      output: (json['output'] as List?)
          ?.map((e) => ResponseItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      status: json['status'] as String?,
      usage: json['usage'] != null
          ? StreamingUsage.fromJson(
              Map<String, dynamic>.from(json['usage'] as Map))
          : null,
      created: (json['created'] as num?)?.toInt(),
      model: json['model'] as String?,
      incompleteDetails: json['incomplete_details'] as String?,
      error: json['error'] != null
          ? ErrorInfo.fromJson(Map<String, dynamic>.from(json['error'] as Map))
          : null,
    );

Map<String, dynamic> _$StreamingResponseEventToJson(
        StreamingResponseEvent instance) =>
    <String, dynamic>{
      if (instance.id != null) 'id': instance.id,
      if (instance.type != null) 'type': instance.type,
      if (instance.delta != null) 'delta': instance.delta,
      if (instance.item != null) 'item': instance.item!.toJson(),
      if (instance.output != null)
        'output': instance.output!.map((e) => e.toJson()).toList(),
      if (instance.status != null) 'status': instance.status,
      if (instance.usage != null) 'usage': instance.usage!.toJson(),
      if (instance.created != null) 'created': instance.created,
      if (instance.model != null) 'model': instance.model,
      if (instance.incompleteDetails != null)
        'incomplete_details': instance.incompleteDetails,
      if (instance.error != null) 'error': instance.error!.toJson(),
    };

StreamingUsage _$StreamingUsageFromJson(Map json) => StreamingUsage(
      inputTokens: (json['input_tokens'] as num?)?.toInt(),
      outputTokens: (json['output_tokens'] as num?)?.toInt(),
      totalTokens: (json['total_tokens'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreamingUsageToJson(StreamingUsage instance) =>
    <String, dynamic>{
      if (instance.inputTokens != null) 'input_tokens': instance.inputTokens,
      if (instance.outputTokens != null) 'output_tokens': instance.outputTokens,
      if (instance.totalTokens != null) 'total_tokens': instance.totalTokens,
    };

Message _$MessageFromJson(Map json) => Message(
      id: json['id'] as String,
      role: json['role'] as String,
      content: (json['content'] as List<dynamic>)
          .map((e) =>
              MessageContent.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'role': instance.role,
      'content': instance.content.map((e) => e.toJson()).toList(),
    };

MessageContent _$MessageContentFromJson(Map json) => MessageContent(
      type: json['type'] as String,
      text: json['text'] as String,
    );

Map<String, dynamic> _$MessageContentToJson(MessageContent instance) =>
    <String, dynamic>{
      'type': instance.type,
      'text': instance.text,
    };