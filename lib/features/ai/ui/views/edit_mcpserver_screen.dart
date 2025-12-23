import 'package:flutter/material.dart';

import '../../../../core/models/mcp/mcp_server.dart';
import '../../../../shared/translate/tl.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/common_dropdown.dart';
import '../../controllers/edit_mcpserver_controller.dart';

class EditMCPServerScreen extends StatefulWidget {
  final MCPServer? server;

  const EditMCPServerScreen({super.key, this.server});

  @override
  State<EditMCPServerScreen> createState() => _EditMCPServerScreenState();
}

class _EditMCPServerScreenState extends State<EditMCPServerScreen> {
  late EditMCPServerViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EditMCPServerViewModel();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.initialize(widget.server);
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _viewModel.isEditMode ? tl('Edit MCP Server') : tl('Add MCP Server'),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 20,
        ),
        actions: [
          if (_viewModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () => _viewModel.saveServer(context),
              tooltip: tl('Save'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Transport Type Selection
            CommonDropdown<MCPTransportType>(
              value: _viewModel.selectedTransport,
              labelText: tl('Transport Type'),
              options: MCPTransportType.values.map((transport) {
                return DropdownOption<MCPTransportType>(
                  value: transport,
                  label: _getTransportLabel(transport),
                  icon: _getTransportIcon(transport),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _viewModel.updateTransport(value);
                }
              },
            ),

            const SizedBox(height: 24),

            // Basic Information
            Text(
              tl('Basic Information'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Server Name
            CustomTextField(
              controller: _viewModel.nameController,
              label: tl('Server Name'),
              hint: tl('Enter a descriptive name for this MCP server'),
              prefixIcon: Icons.dns_outlined,
            ),

            const SizedBox(height: 16),

            // Description (Optional)
            CustomTextField(
              controller: _viewModel.descriptionController,
              label: tl('Description (Optional)'),
              hint: tl('Describe what this server provides'),
              prefixIcon: Icons.description_outlined,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Connection Settings
            if (_viewModel.selectedTransport != MCPTransportType.stdio) ...[
              Text(
                tl('Connection Settings'),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Server URL
              CustomTextField(
                controller: _viewModel.urlController,
                label: tl('Server URL'),
                hint: _getUrlHint(_viewModel.selectedTransport),
                prefixIcon: Icons.link,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 24),

              // Headers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tl('HTTP Headers'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: _viewModel.addHeader,
                    tooltip: tl('Add Header'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Headers List
              if (_viewModel.headers.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          tl(
                            'No headers configured. Add headers for authentication or other custom needs.',
                          ),
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ..._viewModel.headers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final header = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${tl('Header')} ${index + 1}',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const Spacer(),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Theme.of(context).colorScheme.error,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      _viewModel.removeHeader(index),
                                  tooltip: tl('Remove Header'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: header.key,
                                    label: tl('Header Name'),
                                    hint: 'Authorization, Content-Type, etc.',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomTextField(
                                    controller: header.value,
                                    label: tl('Header Value'),
                                    hint:
                                        'Bearer token, application/json, etc.',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ] else ...[
              // STDIO Information
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.terminal,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          tl('STDIO Transport'),
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tl(
                        'STDIO transport is used for local MCP servers that communicate through standard input/output streams. This is typically used for command-line tools and local processes.',
                      ),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Transport Information Card
            _buildTransportInfoCard(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportInfoCard() {
    String title;
    String description;
    IconData icon;
    Color color;

    switch (_viewModel.selectedTransport) {
      case MCPTransportType.sse:
        title = tl('Server-Sent Events (SSE)');
        description = tl(
          'SSE provides real-time communication over HTTP. Best for servers that need to send continuous updates to clients.',
        );
        icon = Icons.stream;
        color = Theme.of(context).colorScheme.primary;
        break;
      case MCPTransportType.streamable:
        title = tl('Streamable HTTP');
        description = tl(
          'Streamable HTTP is the recommended transport for new MCP implementations. It provides efficient bidirectional communication.',
        );
        icon = Icons.http;
        color = Theme.of(context).colorScheme.tertiary;
        break;
      case MCPTransportType.stdio:
        title = tl('Standard I/O (STDIO)');
        description = tl(
          'STDIO transport communicates through standard input/output. Perfect for local command-line tools and processes.',
        );
        icon = Icons.terminal;
        color = Theme.of(context).colorScheme.secondary;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransportLabel(MCPTransportType transport) {
    switch (transport) {
      case MCPTransportType.sse:
        return tl('Server-Sent Events (SSE)');
      case MCPTransportType.streamable:
        return tl('Streamable HTTP');
      case MCPTransportType.stdio:
        return tl('Standard I/O (STDIO)');
    }
  }

  Icon _getTransportIcon(MCPTransportType transport) {
    switch (transport) {
      case MCPTransportType.sse:
        return const Icon(Icons.stream);
      case MCPTransportType.streamable:
        return const Icon(Icons.http);
      case MCPTransportType.stdio:
        return const Icon(Icons.terminal);
    }
  }

  String _getUrlHint(MCPTransportType transport) {
    switch (transport) {
      case MCPTransportType.sse:
        return 'https://example.com/mcp/sse';
      case MCPTransportType.streamable:
        return 'https://example.com/mcp/';
      case MCPTransportType.stdio:
        return '';
    }
  }
}
