import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

/// Base service class for API-compatible providers.
abstract class AIServiceBase {
  final String baseUrl;
  final String? apiKey;
  final Map<String, String> customHeaders;

  const AIServiceBase({
    required this.baseUrl,
    this.apiKey,
    Map<String, String>? headers,
  }) : customHeaders = headers ?? const {};

  String joinUrl(String base, String path) {
    final b = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    final p = path.startsWith('/') ? path.substring(1) : path;
    return '$b/$p';
  }

  Map<String, String> buildHeaders([Map<String, String>? extra]) {
    final base = <String, String>{
      'Content-Type': 'application/json',
      ...customHeaders,
    };
    applyAuthHeaders(base);
    if (extra != null) {
      base.addAll(extra);
    }
    return base;
  }

  /// Hook for providers to inject authentication headers.
  /// Default adds 'Authorization: Bearer {apiKey}' if not present.
  @protected
  void applyAuthHeaders(Map<String, String> headers) {
    if (apiKey != null &&
        apiKey!.isNotEmpty &&
        !headers.containsKey('Authorization')) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
  }

  Future<Map<String, dynamic>> getJson(
    String url, {
    Map<String, String>? headers,
  }) async {
    final res = await http.get(Uri.parse(url), headers: buildHeaders(headers));
    _throwIfNotOk(res, 'GET', url);
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return Map<String, dynamic>.from(decoded as Map);
  }

  Future<Map<String, dynamic>> postJson(
    String url,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final res = await http.post(
      Uri.parse(url),
      headers: buildHeaders(headers),
      body: jsonEncode(body),
    );
    _throwIfNotOk(res, 'POST', url);
    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return Map<String, dynamic>.from(decoded as Map);
  }

  void _throwIfNotOk(http.Response res, String method, String url) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'HTTP $method $url failed (${res.statusCode}): ${res.body}',
      );
    }
  }
}
