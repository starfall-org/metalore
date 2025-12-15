import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/models/ai_model.dart';

Future<List<ModelInfo>> fetchModels(
  String url,
  Map<String, String> headers,
) async {
  late http.Response response;
  response = await http.get(Uri.parse(url), headers: headers);
  if (response.statusCode == 405) {
    response = await http.post(Uri.parse(url), headers: headers);
  }

  if (response.statusCode == 200) {
    final List<dynamic> modelsJson = jsonDecode(response.body);
    List<ModelInfo> models = modelsJson
        .map((model) => ModelInfo.fromJson(model))
        .toList();
    return models;
  } else {
    throw Exception('Failed to load models');
  }
}
