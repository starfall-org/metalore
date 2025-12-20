import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../core/models/ai_agent.dart';
import '../viewmodel/add_agent_viewmodel.dart';
import 'agent_detailed_screen.dart';

class AddAgentScreen extends StatefulWidget {
  final AIAgent? agent;

  const AddAgentScreen({super.key, this.agent});

  @override
  State<AddAgentScreen> createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  late AddAgentViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AddAgentViewModel();
    _viewModel.initialize(widget.agent);
    _viewModel.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _saveAgent() async {
    await _viewModel.saveAgent(widget.agent, context);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.agent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'agents.edit_agent'.tr() : 'agents.add_new_agent'.tr(),
        ),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.info_outline),
              tooltip: 'agents.agent_details'.tr(),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AgentDetailedScreen(agent: widget.agent!),
                  ),
                );
              },
            ),
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAgent),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _viewModel.nameController,
                decoration: InputDecoration(
                  labelText: 'agents.name'.tr(),
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // System Prompt
              TextField(
                controller: _viewModel.promptController,
                maxLines: 6,
                decoration: InputDecoration(
                  labelText: 'agents.system_prompt'.tr(),
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 100),
                    child: Icon(Icons.description_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Parameters Section
              Text(
                'agents.parameters'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text('agents.stream'.tr()),
                        subtitle: Text('agents.stream_desc'.tr()),
                        value: _viewModel.enableStream,
                        onChanged: (value) =>
                            _viewModel.toggleStream(value),
                      ),
                      const Divider(),

                      // Top P
                      SwitchListTile(
                        title: Text('agents.top_p'.tr()),
                        value: _viewModel.isTopPEnabled,
                        onChanged: (value) =>
                            _viewModel.toggleTopP(value),
                      ),
                      if (_viewModel.isTopPEnabled)
                        _buildSlider(
                          value: _viewModel.topPValue,
                          min: 0,
                          max: 1,
                          divisions: 20,
                          label: _viewModel.topPValue.toStringAsFixed(2),
                          onChanged: (v) => _viewModel.setTopPValue(v),
                        ),

                      const Divider(),
                      // Top K
                      SwitchListTile(
                        title: Text('agents.top_k'.tr()),
                        value: _viewModel.isTopKEnabled,
                        onChanged: (value) =>
                            _viewModel.toggleTopK(value),
                      ),
                      if (_viewModel.isTopKEnabled)
                        _buildSlider(
                          value: _viewModel.topKValue,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          label: _viewModel.topKValue.round().toString(),
                          onChanged: (v) => _viewModel.setTopKValue(v),
                        ),

                      const Divider(),
                      // Temperature
                      SwitchListTile(
                        title: Text('agents.temperature'.tr()),
                        value: _viewModel.isTemperatureEnabled,
                        onChanged: (value) =>
                            _viewModel.toggleTemperature(value),
                      ),
                      if (_viewModel.isTemperatureEnabled)
                        _buildSlider(
                          value: _viewModel.temperatureValue,
                          min: 0,
                          max: 2,
                          divisions: 20,
                          label: _viewModel.temperatureValue.toStringAsFixed(2),
                          onChanged: (v) =>
                              _viewModel.setTemperatureValue(v),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Context window etc.
              _buildNumberField(
                label: 'agents.context_window'.tr(),
                value: _viewModel.contextWindowValue,
                onChanged: (v) => _viewModel.setContextWindowValue(v),
                icon: Icons.window_outlined,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                label: 'agents.conversation_length'.tr(),
                value: _viewModel.conversationLengthValue,
                onChanged: (v) => _viewModel.setConversationLengthValue(v),
                icon: Icons.history_outlined,
              ),
              const SizedBox(height: 16),
              _buildNumberField(
                label: 'agents.max_tokens'.tr(),
                value: _viewModel.maxTokensValue,
                onChanged: (v) => _viewModel.setMaxTokensValue(v),
                icon: Icons.token_outlined,
              ),

              const SizedBox(height: 32),

              // Active MCP Servers
              if (_viewModel.availableMCPServers.isNotEmpty) ...[
                Text(
                  'agents.mcp_servers'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: _viewModel.availableMCPServers.map((server) {
                      return CheckboxListTile(
                        title: Text(server.name),
                        value: _viewModel.selectedMCPServerIds.contains(server.id),
                        onChanged: (bool? value) {
                          _viewModel.toggleMCPServer(server.id);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Persist chat selection override
              Text(
                'agents.persist_selection'.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<PersistOverride>(
                  segments: [
                    ButtonSegment(
                      value: PersistOverride.on,
                      label: Text(
                        'agents.persist_on'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ButtonSegment(
                      value: PersistOverride.off,
                      label: Text(
                        'agents.persist_off'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ButtonSegment(
                      value: PersistOverride.disable,
                      label: Text(
                        'agents.persist_disable'.tr(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                  selected: {_viewModel.persistOverride},
                  onSelectionChanged: (Set<PersistOverride> newSelection) {
                    _viewModel.setPersistOverride(newSelection.first);
                  },
                  showSelectedIcon: false,
                ),
              ),
              const SizedBox(height: 48),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _saveAgent,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'common.save'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: label,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 48,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
    required IconData icon,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      controller: TextEditingController(text: value.toString()),
      onChanged: (text) {
        final val = int.tryParse(text);
        if (val != null) onChanged(val);
      },
    );
  }
}
