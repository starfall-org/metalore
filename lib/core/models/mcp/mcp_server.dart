import 'package:uuid/uuid.dart';

export 'mcp_core.dart';
export 'mcp_http.dart';

/// MCP Server Definition
/// Represents a complete MCP server configuration
/// Spec: https://spec.modelcontextprotocol.io/specification/
class MCPServer {
  /// Unique identifier/name for this server configuration
  final String id;
  final String name;

  /// Human-readable description
  final String? description;

  /// Transport protocol type
  final MCPTransportType transport;

  /// Configuration for HTTP transports (required if transport is sse or streamable)
  final MCPHttpConfig? httpConfig;

  /// Server capabilities (discovered after connection)
  final MCPServerCapabilities? capabilities;

  /// Available tools (discovered after connection)
  final List<MCPTool> tools;

  /// Available resources (discovered after connection)
  final List<MCPResource> resources;

  /// Available prompts (discovered after connection)
  final List<MCPPrompt> prompts;

  const MCPServer({
    required this.id,
    required this.name,
    this.description,
    required this.transport,
    this.httpConfig,
    this.capabilities,
    this.tools = const [],
    this.resources = const [],
    this.prompts = const [],
  });

  /// Create a stdio-based MCP server
  factory MCPServer.stdio({
    String? id,
    required String name,
    String? description,
    required String command,
    List<String> args = const [],
    Map<String, String>? env,
    String? cwd,
  }) {
    return MCPServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.stdio,
      httpConfig: null,
    );
  }

  /// Create an SSE-based MCP server
  factory MCPServer.sse({
    String? id,
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
  }) {
    return MCPServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.sse,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
    );
  }

  /// Create a Streamable HTTP-based MCP server
  factory MCPServer.streamable({
    String? id,
    required String name,
    String? description,
    required String url,
    Map<String, String>? headers,
  }) {
    return MCPServer(
      id: id ?? const Uuid().v4(),
      name: name,
      description: description,
      transport: MCPTransportType.streamable,
      httpConfig: MCPHttpConfig(url: url, headers: headers),
    );
  }

  /// Create a copy with updated fields
  MCPServer copyWith({
    String? id,
    String? name,
    String? description,
    MCPTransportType? transport,

    MCPHttpConfig? httpConfig,
    MCPServerCapabilities? capabilities,
    List<MCPTool>? tools,
    List<MCPResource>? resources,
    List<MCPPrompt>? prompts,
  }) {
    return MCPServer(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      transport: transport ?? this.transport,
      httpConfig: httpConfig ?? this.httpConfig,
      capabilities: capabilities ?? this.capabilities,
      tools: tools ?? this.tools,
      resources: resources ?? this.resources,
      prompts: prompts ?? this.prompts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'transport': transport.name,
      if (httpConfig != null) 'httpConfig': httpConfig!.toJson(),
      if (capabilities != null) 'capabilities': capabilities!.toJson(),
      'tools': tools.map((t) => t.toJson()).toList(),
      'resources': resources.map((r) => r.toJson()).toList(),
      'prompts': prompts.map((p) => p.toJson()).toList(),
    };
  }

  factory MCPServer.fromJson(Map<String, dynamic> json) {
    return MCPServer(
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String,
      description: json['description'] as String?,
      transport: MCPTransportType.values.firstWhere(
        (e) => e.name == json['transport'],
        orElse: () => MCPTransportType.sse,
      ),
      httpConfig: json['httpConfig'] != null
          ? MCPHttpConfig.fromJson(json['httpConfig'] as Map<String, dynamic>)
          : null,
      capabilities: json['capabilities'] != null
          ? MCPServerCapabilities.fromJson(
              json['capabilities'] as Map<String, dynamic>,
            )
          : null,
      tools:
          (json['tools'] as List?)
              ?.map((t) => MCPTool.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      resources:
          (json['resources'] as List?)
              ?.map((r) => MCPResource.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      prompts:
          (json['prompts'] as List?)
              ?.map((p) => MCPPrompt.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
