import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/mcp/mcp_server.dart';
import 'base_repository.dart';

class MCPRepository extends BaseRepository<MCPServer> {
  static const String _boxName = 'mcp_servers';

  MCPRepository(super.box);

  static Future<MCPRepository> init() async {
    final box = await Hive.openBox<String>(_boxName);
    return MCPRepository(box);
  }

  @override
  String get boxName => _boxName;

  @override
  MCPServer deserializeItem(String json) {
    return MCPServer.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  @override
  String getItemId(MCPServer item) {
    return item.id;
  }

  @override
  String serializeItem(MCPServer item) {
    return jsonEncode(item.toJson());
  }

  /// Get all enabled servers
  List<MCPServer> getMCPServers() {
    return getItems();
  }
}
