import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../models/chat/message.dart' show ChatMessage, ChatRole;
import 'models.dart';
import '../../../models/ai_model.dart';
import '../base.dart';

class AnthropicService extends AIServiceBase {
  final String anthropicVersion;

  AnthropicService({
    required super.baseUrl,
    super.apiKey,
    super.headers,
    String? anthropicVersion,
  }) : anthropicVersion = anthropicVersion ?? '2023-06-01';

  @override
  void applyAuthHeaders(Map<String, String> headers) {
    // Anthropic requires:
    // - x-api-key
    // - anthropic-version
    headers.putIfAbsent('anthropic-version', () => anthropicVersion);
    if (apiKey != null &&
        apiKey!.isNotEmpty &&
        !headers.containsKey('x-api-key')) {
      headers['x-api-key'] = apiKey!;
    }
    // Intentionally do NOT set Authorization header by default for Anthropic
  }

  // Using joinUrl() from AIServiceBase

  /// GET /models
  /// Returns a list of available models (normalized via OpenAIModelsResponse).
  Future<List<AIModel>> models({
    Map<String, String>? extraHeaders,
    String? customModelsUrl,
  }) async {
    final url = joinUrl(customModelsUrl ?? baseUrl, '/models');
    final res = await http.get(
      Uri.parse(url),
      headers: buildHeaders(extraHeaders),
    );
    if (res.statusCode != 200) {
      throw Exception(
        'Anthropic /models failed (${res.statusCode}): ${res.body}',
      );
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
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      // Normalize Anthropic fields to what AIModel.fromJson expects
      if (m.containsKey('input_token_limit') &&
          !m.containsKey('inputTokenLimit')) {
        m['inputTokenLimit'] = m['input_token_limit'];
      }

      return AIModel.fromJson(m);
    }).toList();
  }

  /// POST /messages (Anthropic Messages API)
  /// Minimal, API-compatible shape with commonly used parameters.
  Future<AnthropicMessagesResponse> messagesCreate({
    required String model,
    required List<Map<String, dynamic>> messages,
    // Common generation params
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    String? system,
    List<String>? stopSequences,
    bool? stream,
    Map<String, dynamic>? metadata,
    // Tools (pass-through)
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    // Extensibility
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) async {
    final url = joinUrl(baseUrl, '/messages');
    final baseBody = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (system != null) 'system': system,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (topK != null) 'top_k': topK,
      if (stopSequences != null) 'stop_sequences': stopSequences,
      if (metadata != null) 'metadata': metadata,
      if (tools != null) 'tools': tools,
      if (toolChoice != null) 'tool_choice': toolChoice,
      ...?extraBody,
    };

    if (stream == true) {
      // SSE streaming mode for Anthropic Messages API
      final headers = buildHeaders({
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
          'Anthropic /messages failed (${err.statusCode}): ${err.body}',
        );
      }

      final completer = Completer<AnthropicMessagesResponse>();
      final buffer = StringBuffer();
      String? stopReason;
      String? messageId;

      streamed.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (!line.startsWith('data: ')) return;
              final data = line.substring(6).trim();
              if (data.isEmpty) return;

              // Anthropic doesn't send [DONE]; it ends with message_stop
              try {
                final obj = jsonDecode(data);
                final t = obj['type']?.toString();

                switch (t) {
                  case 'message_start':
                    final msg = obj['message'];
                    if (msg is Map && msg['id'] != null) {
                      messageId = msg['id'].toString();
                    }
                    break;
                  case 'content_block_delta':
                    // { type: 'content_block_delta', delta: { type: 'text_delta', text: '...' } }
                    final delta = obj['delta'];
                    if (delta is Map && delta['text'] is String) {
                      buffer.write(delta['text'] as String);
                    }
                    break;
                  case 'message_delta':
                    // { type: 'message_delta', delta: { stop_reason: 'end_turn' }, usage: {...} }
                    final d = obj['delta'];
                    if (d is Map && d['stop_reason'] != null) {
                      stopReason = d['stop_reason'].toString();
                    }
                    break;
                  case 'message_stop':
                    // End of stream - finalize response
                    final raw = {
                      'id': messageId,
                      'type': 'message',
                      'role': 'assistant',
                      'model': model,
                      'stop_reason': stopReason,
                      'stop_sequence': null,
                      'content': [
                        {'type': 'text', 'text': buffer.toString()},
                      ],
                      // usage unavailable cumulatively here; providers may emit only deltas
                    };
                    if (!completer.isCompleted) {
                      completer.complete(
                        AnthropicMessagesResponse.fromJson(
                          Map<String, dynamic>.from(raw),
                        ),
                      );
                    }
                    break;
                  default:
                    // ignore other event types: content_block_start/stop, ping, etc.
                    break;
                }
              } catch (_) {
                // ignore malformed chunk
              }
            },
            onError: (e) {
              if (!completer.isCompleted) completer.completeError(e);
              client.close();
            },
            onDone: () {
              // If stream ends without explicit message_stop, still complete with what we have
              if (!completer.isCompleted) {
                final raw = {
                  'id': messageId,
                  'type': 'message',
                  'role': 'assistant',
                  'model': model,
                  'stop_reason': stopReason,
                  'stop_sequence': null,
                  'content': [
                    {'type': 'text', 'text': buffer.toString()},
                  ],
                };
                completer.complete(
                  AnthropicMessagesResponse.fromJson(
                    Map<String, dynamic>.from(raw),
                  ),
                );
              }
              client.close();
            },
          );

      return completer.future;
    }

    // Non-streaming request
    final res = await http.post(
      Uri.parse(url),
      headers: buildHeaders(extraHeaders),
      body: jsonEncode({...baseBody, 'stream': false}),
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Anthropic /messages failed (${res.statusCode}): ${res.body}',
      );
    }
    return AnthropicMessagesResponse.fromJson(
      Map<String, dynamic>.from(jsonDecode(res.body)),
    );
  }

  /// Convert internal Message list to Anthropic Messages shape.
  /// - ChatRole.user -> 'user'
  /// - ChatRole.model -> 'assistant'
  /// - ChatRole.system is omitted (use `system` parameter)
  /// - ChatRole.tool is omitted (use tools/tool results accordingly)
  static List<Map<String, dynamic>> toAnthropicMessages(
    List<ChatMessage> msgs,
  ) {
    final List<Map<String, dynamic>> out = [];
    for (final m in msgs) {
      switch (m.role) {
        case ChatRole.user:
          out.add({'role': 'user', 'content': m.content});
          break;
        case ChatRole.model:
          out.add({'role': 'assistant', 'content': m.content});
          break;
        case ChatRole.system:
          // Skip; caller aggregates into `system`
          break;
        case ChatRole.tool:
          // Skip; tool I/O not mapped by default
          break;
      }
    }
    return out;
  }

  /// Concatenate system messages into one system prompt.
  static String? extractSystemPrompt(List<ChatMessage> msgs) {
    final buf = StringBuffer();
    for (final m in msgs) {
      if (m.role == ChatRole.system && m.content.isNotEmpty) {
        if (buf.isNotEmpty) buf.write('\n\n');
        buf.write(m.content);
      }
    }
    return buf.isEmpty ? null : buf.toString();
  }

  /// Real-time streaming cho Anthropic Messages API (emit text delta ngay khi đến).
  /// Trả về Stream<String> để hiển thị realtime (không đợi kết thúc).
  Stream<String> messagesStream({
    required String model,
    required List<Map<String, dynamic>> messages,
    int? maxTokens,
    double? temperature,
    double? topP,
    int? topK,
    String? system,
    List<String>? stopSequences,
    Map<String, dynamic>? metadata,
    List<Map<String, dynamic>>? tools,
    dynamic toolChoice,
    Map<String, dynamic>? extraBody,
    Map<String, String>? extraHeaders,
  }) {
    final url = joinUrl(baseUrl, '/messages');

    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (system != null) 'system': system,
      if (maxTokens != null) 'max_tokens': maxTokens,
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (topK != null) 'top_k': topK,
      if (stopSequences != null) 'stop_sequences': stopSequences,
      if (metadata != null) 'metadata': metadata,
      if (tools != null) 'tools': tools,
      if (toolChoice != null) 'tool_choice': toolChoice,
      ...?extraBody,
      'stream': true,
    };

    final headers = buildHeaders({
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
        // Controller sẽ được đóng qua onDone/onError.
      },
    );

    client.send(req).then((streamed) async {
      if (streamed.statusCode != 200) {
        final err = await http.Response.fromStream(streamed);
        controller.addError(Exception(
          'Anthropic /messages failed (${err.statusCode}): ${err.body}',
        ));
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
          if (data.isEmpty) return;

          try {
            final obj = jsonDecode(data);
            final type = obj['type']?.toString();

            switch (type) {
              case 'content_block_delta':
                // { type: 'content_block_delta', delta: { type: 'text_delta', text: '...' } }
                final delta = obj['delta'];
                if (delta is Map) {
                  final text = delta['text'];
                  if (text is String && text.isNotEmpty) {
                    controller.add(text);
                  }
                }
                break;

              case 'message_stop':
                // Kết thúc stream theo chuẩn Anthropic
                controller.close();
                client.close();
                break;

              // Các event khác: message_start, content_block_start/stop, message_delta, ping...
              default:
                // Bỏ qua các event không mang delta text
                break;
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
