import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../../models/chat/message.dart' show ChatMessage, ChatRole;
import '../../../models/ai_model.dart';
import '../base.dart';
import 'models.dart';

class OpenAIService extends AIServiceBase {
  OpenAIService({required super.baseUrl, super.apiKey, super.headers});

  Map<String, String> _buildHeaders([Map<String, String>? extra]) {
    return buildHeaders(extra);
  }

  String _join(String base, String path) {
    return joinUrl(base, path);
  }

  Future<List<AIModel>> models({
    Map<String, String>? extraHeaders,
    String? customModelsUrl,
  }) async {
    final url = _join(customModelsUrl ?? baseUrl, '/models');
    final res = await http.get(
      Uri.parse(url),
      headers: _buildHeaders(extraHeaders),
    );
    if (res.statusCode != 200) {
      throw Exception('OpenAI /models failed (${res.statusCode}): ${res.body}');
    }
    final decoded = jsonDecode(res.body);
    List list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic> && decoded['data'] is List) {
      list = decoded['data'] as List;
    } else {
      list = const [];
    }
    return list
        .whereType<Map>()
        .map((e) => AIModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<OpenAIChatCompletionsResponse> chatCompletions({
    required String model,
    required List<Map<String, dynamic>> messages,
    double? temperature,
    double? topP,
    int? n,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, num>? logitBias,
    bool? logprobs,
    int? topLogprobs,
    dynamic stop,
    Map<String, dynamic>? responseFormat,
    int? seed,
    String? serviceTier,
    bool? stream,
    Map<String, dynamic>? streamOptions,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    bool? parallelToolCalls,
    String? user,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/chat/completions');
    final baseBody = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (n != null) 'n': n,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (presencePenalty != null) 'presence_penalty': presencePenalty,
      if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
      if (logitBias != null && logitBias.isNotEmpty) 'logit_bias': logitBias,
      if (logprobs != null) 'logprobs': logprobs,
      if (topLogprobs != null) 'top_logprobs': topLogprobs,
      if (stop != null) 'stop': stop,
      if (responseFormat != null) 'response_format': responseFormat,
      if (seed != null) 'seed': seed,
      if (serviceTier != null) 'service_tier': serviceTier,
      if (streamOptions != null) 'stream_options': streamOptions,
      if (tools != null) 'tools': tools,
      if (toolChoice != null) 'tool_choice': toolChoice,
      if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
      if (user != null) 'user': user,
      ...?extraBody,
    };

    if (stream == true) {
      final headers = _buildHeaders({
        ...?extraHeaders,
        'Accept': 'text/event-stream',
      });
      final req = http.Request('POST', Uri.parse(url));
      req.headers.addAll(headers);
      req.body = jsonEncode({...baseBody, 'stream': true});
      final client = http.Client();
      final streamed = await client.send(req);
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        client.close();
        throw Exception(
          'OpenAI /chat/completions failed (${err.statusCode}): ${err.body}',
        );
      }
      final completer = Completer<OpenAIChatCompletionsResponse>();
      final buffer = StringBuffer();
      String? finishReason;

      streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('data: ')) {
                final data = line.substring(6).trim();
                if (data == '[DONE]') {
                  final json = {
                    'id': null,
                    'object': 'chat.completion',
                    'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    'model': model,
                    'choices': [
                      {
                        'index': 0,
                        'message': {
                          'role': 'assistant',
                          'content': buffer.toString(),
                        },
                        'finish_reason': finishReason ?? 'stop',
                      },
                    ],
                  };
                  if (!completer.isCompleted) {
                    completer.complete(
                      OpenAIChatCompletionsResponse.fromJson(
                        Map<String, dynamic>.from(json),
                      ),
                    );
                  }
                } else {
                  try {
                    final obj = jsonDecode(data);
                    final ch = obj['choices'];
                    if (ch is List && ch.isNotEmpty) {
                      final delta = ch[0]['delta'];
                      if (delta is Map) {
                        final c = delta['content'];
                        if (c is String) buffer.write(c);
                      }
                      final fr = ch[0]['finish_reason'];
                      if (fr != null) finishReason = fr.toString();
                    }
                  } catch (_) {
                    // ignore malformed chunk
                  }
                }
              }
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
              client.close();
            },
            onDone: () {
              if (!completer.isCompleted) {
                final json = {
                  'id': null,
                  'object': 'chat.completion',
                  'created': DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  'model': model,
                  'choices': [
                    {
                      'index': 0,
                      'message': {
                        'role': 'assistant',
                        'content': buffer.toString(),
                      },
                      'finish_reason': finishReason ?? 'stop',
                    },
                  ],
                };
                completer.complete(
                  OpenAIChatCompletionsResponse.fromJson(
                    Map<String, dynamic>.from(json),
                  ),
                );
              }
              client.close();
            },
          );

      return completer.future;
    }

    final res = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(extraHeaders),
      body: jsonEncode({...baseBody, 'stream': false}),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /chat/completions failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIChatCompletionsResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIEmbeddingsResponse> embeddings({
    required String model,
    required dynamic input,
    String? encodingFormat,
    int? dimensions,
    String? user,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/embeddings');
    final body = <String, dynamic>{
      'model': model,
      'input': input,
      if (encodingFormat != null) 'encoding_format': encodingFormat,
      if (dimensions != null) 'dimensions': dimensions,
      if (user != null) 'user': user,
      ...?extraBody,
    };
    final res = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(extraHeaders),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /embeddings failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIEmbeddingsResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIResponsesResponse> responses({
    required String model,
    String? input,
    List<Map<String, dynamic>>? messages,
    List<String>? modalities,
    Map<String, dynamic>? audio,
    Map<String, dynamic>? video,
    Map<String, dynamic>? image,
    String? instructions,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    int? maxOutputTokens,
    Map<String, dynamic>? responseFormat,
    int? seed,
    bool? stream,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/responses');
    final baseBody = <String, dynamic>{
      'model': model,
      if (input != null) 'input': input,
      if (messages != null) 'messages': messages,
      if (modalities != null) 'modalities': modalities,
      if (audio != null) 'audio': audio,
      if (video != null) 'video': video,
      if (image != null) 'image': image,
      if (instructions != null) 'instructions': instructions,
      if (tools != null) 'tools': tools,
      if (toolChoice != null) 'tool_choice': toolChoice,
      if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
      if (responseFormat != null) 'response_format': responseFormat,
      if (seed != null) 'seed': seed,
      ...?extraBody,
    };

    if (stream == true) {
      final headers = _buildHeaders({
        ...?extraHeaders,
        'Accept': 'text/event-stream',
      });
      final req = http.Request('POST', Uri.parse(url));
      req.headers.addAll(headers);
      req.body = jsonEncode({...baseBody, 'stream': true});
      final client = http.Client();
      final streamed = await client.send(req);
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        client.close();
        throw Exception(
          'OpenAI /responses failed (${err.statusCode}): ${err.body}',
        );
      }
      final completer = Completer<OpenAIResponsesResponse>();
      final buffer = StringBuffer();

      streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.startsWith('data: ')) {
                final data = line.substring(6).trim();
                if (data == '[DONE]') {
                  final raw = {
                    'id': null,
                    'model': model,
                    'output_text': buffer.toString(),
                  };
                  if (!completer.isCompleted) {
                    completer.complete(
                      OpenAIResponsesResponse.fromJson(
                        Map<String, dynamic>.from(raw),
                      ),
                    );
                  }
                } else {
                  try {
                    final obj = jsonDecode(data);
                    if (obj['delta'] is String) {
                      buffer.write(obj['delta'] as String);
                    } else if (obj['output_text'] is String) {
                      buffer.write(obj['output_text'] as String);
                    } else if (obj['choices'] is List &&
                        (obj['choices'] as List).isNotEmpty) {
                      final ch = (obj['choices'] as List).first;
                      if (ch is Map && ch['delta'] is Map) {
                        final c = (ch['delta'] as Map)['content'];
                        if (c is String) buffer.write(c);
                      }
                    }
                  } catch (_) {
                    // ignore malformed chunk
                  }
                }
              }
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
              client.close();
            },
            onDone: () {
              if (!completer.isCompleted) {
                final raw = {
                  'id': null,
                  'model': model,
                  'output_text': buffer.toString(),
                };
                completer.complete(
                  OpenAIResponsesResponse.fromJson(
                    Map<String, dynamic>.from(raw),
                  ),
                );
              }
              client.close();
            },
          );

      return completer.future;
    }

    final res = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(extraHeaders),
      body: jsonEncode({...baseBody, 'stream': false}),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /responses failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIResponsesResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIAudioSpeechResponse> audioSpeech({
    required String model,
    required String input,
    String? voice,
    String? format,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/audio/speech');
    final headers = _buildHeaders({
      ...?extraHeaders,
      'Accept': 'application/octet-stream',
    });
    final body = <String, dynamic>{
      'model': model,
      'input': input,
      if (voice != null) 'voice': voice,
      if (format != null) 'format': format,
      ...?extraBody,
    };
    final res = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /audio/speech failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIAudioSpeechResponse(
      bytes: res.bodyBytes,
      contentType: res.headers['content-type'],
    );
  }

  Future<OpenAIAudioTranscriptionResponse> audioTranscriptions({
    required String model,
    required Uint8List fileBytes,
    required String fileName,
    String? prompt,
    String? responseFormat,
    double? temperature,
    String? language,
    Map<String, String>? extraHeaders,
    Map<String, String>? extraFields,
  }) async {
    final url = _join(baseUrl, '/audio/transcriptions');
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_buildHeaders(extraHeaders));
    request.fields['model'] = model;
    if (prompt != null) request.fields['prompt'] = prompt;
    if (responseFormat != null) {
      request.fields['response_format'] = responseFormat;
    }
    if (temperature != null) {
      request.fields['temperature'] = temperature.toString();
    }
    if (language != null) request.fields['language'] = language;
    if (extraFields != null) request.fields.addAll(extraFields);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /audio/transcriptions failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIAudioTranscriptionResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIAudioTranslationResponse> audioTranslations({
    required String model,
    required Uint8List fileBytes,
    required String fileName,
    String? prompt,
    String? responseFormat,
    double? temperature,
    Map<String, String>? extraHeaders,
    Map<String, String>? extraFields,
  }) async {
    final url = _join(baseUrl, '/audio/translations');
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_buildHeaders(extraHeaders));
    request.fields['model'] = model;
    if (prompt != null) request.fields['prompt'] = prompt;
    if (responseFormat != null) {
      request.fields['response_format'] = responseFormat;
    }
    if (temperature != null) {
      request.fields['temperature'] = temperature.toString();
    }
    if (extraFields != null) request.fields.addAll(extraFields);
    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /audio/translations failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIAudioTranslationResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIImagesResponse> imagesGenerations({
    required String prompt,
    String? model,
    int? n,
    String? size,
    String? quality,
    String? style,
    String? background,
    String? responseFormat,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/images/generations');
    final body = <String, dynamic>{
      if (model != null) 'model': model,
      'prompt': prompt,
      if (n != null) 'n': n,
      if (size != null) 'size': size,
      if (quality != null) 'quality': quality,
      if (style != null) 'style': style,
      if (background != null) 'background': background,
      if (responseFormat != null) 'response_format': responseFormat,
      ...?extraBody,
    };
    final res = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(extraHeaders),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /images/generations failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIImagesResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIImagesResponse> imagesEdits({
    required List<Uint8List> images,
    required String prompt,
    String? model,
    Uint8List? mask,
    int? n,
    String? size,
    String? quality,
    String? style,
    String? background,
    String? responseFormat,
    Map<String, String>? extraHeaders,
    Map<String, String>? extraFields,
  }) async {
    final url = _join(baseUrl, '/images/edits');
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_buildHeaders(extraHeaders));
    request.fields['prompt'] = prompt;
    if (model != null) request.fields['model'] = model;
    if (n != null) request.fields['n'] = n.toString();
    if (size != null) request.fields['size'] = size;
    if (quality != null) request.fields['quality'] = quality;
    if (style != null) request.fields['style'] = style;
    if (background != null) request.fields['background'] = background;
    if (responseFormat != null) {
      request.fields['response_format'] = responseFormat;
    }
    if (extraFields != null) request.fields.addAll(extraFields);
    for (var i = 0; i < images.length; i++) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          images[i],
          filename: 'image_$i.png',
        ),
      );
    }
    if (mask != null) {
      request.files.add(
        http.MultipartFile.fromBytes('mask', mask, filename: 'mask.png'),
      );
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /images/edits failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIImagesResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIImagesResponse> imagesVariations({
    required Uint8List image,
    String? model,
    int? n,
    String? size,
    String? quality,
    String? style,
    String? responseFormat,
    Map<String, String>? extraHeaders,
    Map<String, String>? extraFields,
  }) async {
    final url = _join(baseUrl, '/images/variations');
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_buildHeaders(extraHeaders));
    if (model != null) request.fields['model'] = model;
    if (n != null) request.fields['n'] = n.toString();
    if (size != null) request.fields['size'] = size;
    if (quality != null) request.fields['quality'] = quality;
    if (style != null) request.fields['style'] = style;
    if (responseFormat != null) {
      request.fields['response_format'] = responseFormat;
    }
    if (extraFields != null) request.fields.addAll(extraFields);
    request.files.add(
      http.MultipartFile.fromBytes('image', image, filename: 'image.png'),
    );
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /images/variations failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIImagesResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  Future<OpenAIVideosResponse> videosGenerations({
    required String model,
    required String prompt,
    int? duration,
    String? size,
    String? format,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = _join(baseUrl, '/videos/generations');
    final body = <String, dynamic>{
      'model': model,
      'prompt': prompt,
      if (duration != null) 'duration': duration,
      if (size != null) 'size': size,
      if (format != null) 'format': format,
      ...?extraBody,
    };
    final res = await http.post(
      Uri.parse(url),
      headers: _buildHeaders(extraHeaders),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'OpenAI /videos/generations failed (${res.statusCode}): ${res.body}',
      );
    }
    return OpenAIVideosResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  static List<Map<String, dynamic>> toOpenAIMessages(List<ChatMessage> msgs) {
    return msgs.map((m) {
      final role = switch (m.role) {
        ChatRole.user => 'user',
        ChatRole.model => 'assistant',
        ChatRole.system => 'system',
        ChatRole.tool => 'tool',
      };
      return {'role': role, 'content': m.content};
    }).toList();
  }

  /// Real-time streaming cho Chat Completions (trả về delta content ngay khi đến)
  Stream<String> chatCompletionsStream({
    required String model,
    required List<Map<String, dynamic>> messages,
    double? temperature,
    double? topP,
    int? n,
    int? maxTokens,
    double? presencePenalty,
    double? frequencyPenalty,
    Map<String, num>? logitBias,
    bool? logprobs,
    int? topLogprobs,
    dynamic stop,
    Map<String, dynamic>? responseFormat,
    int? seed,
    String? serviceTier,
    Map<String, dynamic>? streamOptions,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    bool? parallelToolCalls,
    String? user,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) {
    final url = _join(baseUrl, '/chat/completions');

    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (n != null) 'n': n,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (presencePenalty != null) 'presence_penalty': presencePenalty,
      if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
      if (logitBias != null && logitBias.isNotEmpty) 'logit_bias': logitBias,
      if (logprobs != null) 'logprobs': logprobs,
      if (topLogprobs != null) 'top_logprobs': topLogprobs,
      if (stop != null) 'stop': stop,
      if (responseFormat != null) 'response_format': responseFormat,
      if (seed != null) 'seed': seed,
      if (serviceTier != null) 'service_tier': serviceTier,
      if (streamOptions != null) 'stream_options': streamOptions,
      if (tools != null) 'tools': tools,
      if (toolChoice != null) 'tool_choice': toolChoice,
      if (parallelToolCalls != null) 'parallel_tool_calls': parallelToolCalls,
      if (user != null) 'user': user,
      ...?extraBody,
      'stream': true,
    };

    final headers = _buildHeaders({
      ...?extraHeaders,
      'Accept': 'text/event-stream',
    });

    final req = http.Request('POST', Uri.parse(url));
    req.headers.addAll(headers);
    req.body = jsonEncode(body);
    final client = http.Client();

    late StreamSubscription<String> sub;
    final controller = StreamController<String>(
      onCancel: () async {
        try {
          await sub.cancel();
        } catch (_) {}
        client.close();
        // Controller will be closed via onDone/onError paths.
      },
    );

    client.send(req).then((streamed) async {
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        controller.addError(Exception(
          'OpenAI /chat/completions failed (${err.statusCode}): ${err.body}',
        ));
        await controller.close();
        client.close();
        return;
      }

      sub = streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (!line.startsWith('data: ')) return;
          final data = line.substring(6).trim();
          if (data == '[DONE]') {
            controller.close();
            client.close();
            return;
          }
          try {
            final obj = jsonDecode(data);
            // Chuẩn OpenAI: choices[0].delta.content
            final ch = obj['choices'];
            if (ch is List && ch.isNotEmpty) {
              final delta = ch[0]['delta'];
              if (delta is Map) {
                final c = delta['content'];
                if (c is String && c.isNotEmpty) controller.add(c);
              }
              // Một số server có thể gửi message.content trọn vẹn trong stream
              final msg = ch[0]['message'];
              if (msg is Map) {
                final c2 = msg['content'];
                if (c2 is String && c2.isNotEmpty) controller.add(c2);
              }
            }
          } catch (_) {
            // Bỏ qua chunk không hợp lệ
          }
        },
        onError: (e, st) async {
          controller.addError(e, st);
          await controller.close();
          client.close();
        },
        onDone: () async {
          await controller.close();
          client.close();
        },
        cancelOnError: false,
      );
    }).catchError((e, st) async {
      controller.addError(e, st);
      await controller.close();
      client.close();
    });

    return controller.stream;
  }

  /// Real-time streaming cho Responses API (trả về delta text ngay khi đến)
  Stream<String> responsesStream({
    required String model,
    String? input,
    List<Map<String, dynamic>>? messages,
    List<String>? modalities,
    Map<String, dynamic>? audio,
    Map<String, dynamic>? video,
    Map<String, dynamic>? image,
    String? instructions,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    int? maxOutputTokens,
    Map<String, dynamic>? responseFormat,
    int? seed,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) {
    final url = _join(baseUrl, '/responses');

    final body = <String, dynamic>{
      'model': model,
      if (input != null) 'input': input,
      if (messages != null) 'messages': messages,
      if (modalities != null) 'modalities': modalities,
      if (audio != null) 'audio': audio,
      if (video != null) 'video': video,
      if (image != null) 'image': image,
      if (instructions != null) 'instructions': instructions,
      if (tools != null) 'tools': tools,
      if (toolChoice != null) 'tool_choice': toolChoice,
      if (maxOutputTokens != null) 'max_output_tokens': maxOutputTokens,
      if (responseFormat != null) 'response_format': responseFormat,
      if (seed != null) 'seed': seed,
      ...?extraBody,
      'stream': true,
    };

    final headers = _buildHeaders({
      ...?extraHeaders,
      'Accept': 'text/event-stream',
    });

    final req = http.Request('POST', Uri.parse(url));
    req.headers.addAll(headers);
    req.body = jsonEncode(body);
    final client = http.Client();

    late StreamSubscription<String> sub;
    final controller = StreamController<String>(
      onCancel: () async {
        try {
          await sub.cancel();
        } catch (_) {}
        client.close();
        // Controller will be closed via onDone/onError paths.
      },
    );

    client.send(req).then((streamed) async {
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        controller.addError(Exception(
          'OpenAI /responses failed (${err.statusCode}): ${err.body}',
        ));
        await controller.close();
        client.close();
        return;
      }

      sub = streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (!line.startsWith('data: ')) return;
          final data = line.substring(6).trim();
          if (data == '[DONE]') {
            controller.close();
            client.close();
            return;
          }
          try {
            final obj = jsonDecode(data);

            // Một số biến thể event của Responses API:
            // 1) {"delta": "text..."}
            final deltaStr = obj['delta'];
            if (deltaStr is String && deltaStr.isNotEmpty) {
              controller.add(deltaStr);
              return;
            }

            // 2) {"output_text": "text..."}
            final outputText = obj['output_text'];
            if (outputText is String && outputText.isNotEmpty) {
              controller.add(outputText);
              return;
            }

            // 3) {"choices":[{"delta":{"content":"text..."}}]}
            final ch = obj['choices'];
            if (ch is List && ch.isNotEmpty) {
              final d = ch.first['delta'];
              if (d is Map) {
                final c = d['content'];
                if (c is String && c.isNotEmpty) {
                  controller.add(c);
                  return;
                }
              }
            }
          } catch (_) {
            // Bỏ qua chunk không hợp lệ
          }
        },
        onError: (e, st) async {
          controller.addError(e, st);
          await controller.close();
          client.close();
        },
        onDone: () async {
          await controller.close();
          client.close();
        },
        cancelOnError: false,
      );
    }).catchError((e, st) async {
      controller.addError(e, st);
      await controller.close();
      client.close();
    });

    return controller.stream;
  }
}
