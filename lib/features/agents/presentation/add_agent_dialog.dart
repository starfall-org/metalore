import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/storage/agent_repository.dart';
import '../../../core/storage/mcp_repository.dart';
import '../../../core/models/ai_agent.dart';
import '../../../core/models/mcp/mcp_server.dart';

enum _PersistOverride { followGlobal, forceOn, forceOff }

class AddAgentDialog extends StatefulWidget {
  const AddAgentDialog({super.key});

  @override
  State<AddAgentDialog> createState() => _AddAgentDialogState();
}

class _AddAgentDialogState extends State<AddAgentDialog> {
  final _nameController = TextEditingController();
  final _promptController = TextEditingController();
  final bool _isTopPEnabled = false;
  final double _topPValue = 1.0;
  bool _isTopKEnabled = false;
  double _topKValue = 40.0;
  bool _isTemperatureEnabled = false;
  double _temperatureValue = 0.7;
  int _contextWindowValue = 60000;
  int _conversationLengthValue = 10;
  int _maxTokensValue = 4000;
  List<MCPServer> _availableMCPServers = [];
  final List<String> _selectedMCPServerIds = [];

  // Persist selection override for this agent: null => follow global; true/false => override
  _PersistOverride _persistOverride = _PersistOverride.followGlobal;

  @override
  void initState() {
    super.initState();
    _loadMCPServers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadMCPServers() async {
    final mcpRepo = await MCPRepository.init();
    setState(() {
      _availableMCPServers = mcpRepo.getMCPServers();
    });
  }

  Future<void> _saveAgent() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('agents.name'.tr())),
      );
      return;
    }

    final repository = await AgentRepository.init();
    final newAgent = AIAgent(
      id: const Uuid().v4(),
      name: _nameController.text,
      systemPrompt: _promptController.text,
      topP: _isTopPEnabled ? _topPValue : null,
      topK: _isTopKEnabled ? _topKValue : null,
      temperature: _isTemperatureEnabled ? _temperatureValue : null,
      contextWindow: _contextWindowValue,
      conversationLength: _conversationLengthValue,
      maxTokens: _maxTokensValue,
      activeMCPServerIds: _selectedMCPServerIds,
      persistChatSelection: _persistOverride == _PersistOverride.followGlobal
          ? null
          : (_persistOverride == _PersistOverride.forceOn),
    );

    await repository.addAgent(newAgent);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.1, // 80% width
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'agents.add_new_agent'.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Avatar Section
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Agent Name
                   TextField(
                     controller: _nameController,
                     decoration: InputDecoration(
                       labelText: 'agents.name'.tr(),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                       filled: true,
                       fillColor: Colors.grey.shade50,
                     ),
                   ),
                   const SizedBox(height: 16),

                   // System Prompt
                   TextField(
                     controller: _promptController,
                     maxLines: 3,
                     decoration: InputDecoration(
                       labelText: 'agents.system_prompt'.tr(),
                       alignLabelWithHint: true,
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                       filled: true,
                       fillColor: Colors.grey.shade50,
                     ),
                   ),
                    const SizedBox(height: 24),

                    // Parameters
                    Text(
                      'agents.parameters'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Top K
                    SwitchListTile(
                      title: Text('agents.top_k'.tr()),
                      value: _isTopKEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isTopKEnabled = value;
                        });
                      },
                    ),
                    if (_isTopKEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _topKValue,
                                min: 1,
                                max: 100,
                                divisions: 99,
                                label: _topKValue.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _topKValue = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              _topKValue.round().toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Temperature
                    SwitchListTile(
                      title: const Text('Temperature'),
                      value: _isTemperatureEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isTemperatureEnabled = value;
                        });
                      },
                    ),
                    if (_isTemperatureEnabled)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: _temperatureValue,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: _temperatureValue.toString(),
                                onChanged: (value) {
                                  setState(() {
                                    _temperatureValue = value;
                                  });
                                },
                              ),
                            ),
                            Text(
                              _temperatureValue.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                   // Context Window
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 8),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('agents.context_window'.tr()),
                         const SizedBox(height: 8),
                         Row(
                           children: [
                             Expanded(
                               child: TextField(
                                 keyboardType: TextInputType.number,
                                 controller: TextEditingController(
                                   text: _contextWindowValue.toString(),
                                 ),
                                 decoration: InputDecoration(
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   filled: true,
                                   fillColor: Colors.grey.shade50,
                                 ),
                                 onChanged: (value) {
                                   _contextWindowValue = int.tryParse(value) ?? 60000;
                                 },
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   // Conversation Length
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 8),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('agents.conversation_length'.tr()),
                         const SizedBox(height: 8),
                         Row(
                           children: [
                             Expanded(
                               child: TextField(
                                 keyboardType: TextInputType.number,
                                 controller: TextEditingController(
                                   text: _conversationLengthValue.toString(),
                                 ),
                                 decoration: InputDecoration(
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   filled: true,
                                   fillColor: Colors.grey.shade50,
                                 ),
                                 onChanged: (value) {
                                   _conversationLengthValue = int.tryParse(value) ?? 10;
                                 },
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   // Max Tokens
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 8),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('agents.max_tokens'.tr()),
                         const SizedBox(height: 8),
                         Row(
                           children: [
                             Expanded(
                               child: TextField(
                                 keyboardType: TextInputType.number,
                                 controller: TextEditingController(
                                   text: _maxTokensValue.toString(),
                                 ),
                                 decoration: InputDecoration(
                                   border: OutlineInputBorder(
                                     borderRadius: BorderRadius.circular(12),
                                   ),
                                   filled: true,
                                   fillColor: Colors.grey.shade50,
                                 ),
                                 onChanged: (value) {
                                   _maxTokensValue = int.tryParse(value) ?? 4000;
                                 },
                               ),
                             ),
                           ],
                         ),
                       ],
                     ),
                   ),

                   // Active MCP Servers
                   if (_availableMCPServers.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.symmetric(vertical: 8),
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text('agents.active_mcp_servers'.tr()),
                           const SizedBox(height: 8),
                           ..._availableMCPServers.map((server) {
                             return CheckboxListTile(
                               title: Text(server.name),
                               value: _selectedMCPServerIds.contains(server.id),
                               onChanged: (bool? value) {
                                 setState(() {
                                   if (value == true) {
                                     _selectedMCPServerIds.add(server.id);
                                   } else {
                                     _selectedMCPServerIds.remove(server.id);
                                   }
                                 });
                               },
                             );
                           }),
                         ],
                       ),
                     ),

                   // Persist chat selection override (Agent-level)
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 8),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text('agents.persist_section_title'.tr()),
                         const SizedBox(height: 8),
                         RadioListTile<_PersistOverride>(
                           title: Text('agents.persist_follow_global'.tr()),
                           value: _PersistOverride.followGlobal,
                           groupValue: _persistOverride,
                           onChanged: (val) {
                             if (val != null) {
                               setState(() => _persistOverride = val);
                             }
                           },
                         ),
                         RadioListTile<_PersistOverride>(
                           title: Text('agents.persist_force_on'.tr()),
                           value: _PersistOverride.forceOn,
                           groupValue: _persistOverride,
                           onChanged: (val) {
                             if (val != null) {
                               setState(() => _persistOverride = val);
                             }
                           },
                         ),
                         RadioListTile<_PersistOverride>(
                           title: Text('agents.persist_force_off'.tr()),
                           value: _PersistOverride.forceOff,
                           groupValue: _persistOverride,
                           onChanged: (val) {
                             if (val != null) {
                               setState(() => _persistOverride = val);
                             }
                           },
                         ),
                       ],
                     ),
                   ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('agents.cancel'.tr()),
                ),
                const SizedBox(width: 16),
                FilledButton(
                  onPressed: _saveAgent,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text('agents.save'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
