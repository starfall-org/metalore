import 'package:flutter/material.dart';
import '../../../core/storage/agent_repository.dart';
import '../../../core/models/ai_agent.dart';
import 'add_agent_dialog.dart';
import '../../../core/widgets/resource_tile.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/grid_card.dart';

class AgentListScreen extends StatefulWidget {
  const AgentListScreen({super.key});

  @override
  State<AgentListScreen> createState() => _AgentListScreenState();
}

class _AgentListScreenState extends State<AgentListScreen> {
  List<AIAgent> _agents = [];
  bool _isLoading = true;
  late AgentRepository _repository;

  @override
  void initState() {
    super.initState();
    _loadAgents();
  }

  Future<void> _loadAgents() async {
    _repository = await AgentRepository.init();
    if (!mounted) return;
    setState(() {
      _agents = _repository.getAgents();
      _isLoading = false;
    });
  }

  Future<void> _deleteAgent(String id) async {
    await _repository.deleteAgent(id);
    _loadAgents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Agent'),
        actions: [
          AddAction(
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (context) => const AddAgentDialog(),
              );
              if (result == true) {
                _loadAgents();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _agents.isEmpty
              ? EmptyState(
                  message: 'No agents',
                  actionLabel: 'Add Agent',
                  onAction: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (context) => const AddAgentDialog(),
                    );
                    if (result == true) {
                      _loadAgents();
                    }
                  },
                )
              : ListView.builder(
                  itemCount: _agents.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, index) {
                    final agent = _agents[index];
                    return ResourceTile(
                      title: agent.name,
                      subtitle: agent.systemPrompt.isNotEmpty
                          ? agent.systemPrompt
                          : 'No system prompt',
                      leadingIcon: Icons.smart_toy,
                      onTap: () async {
                        await _repository.setSelectedAgentId(agent.id);
                        if (!context.mounted) return;
                        Navigator.pop(context, true);
                      },
                      onDelete: () => _confirmDelete(agent),
                    );
                  },
                ),
    );
  }

  Future<void> _confirmDelete(AIAgent agent) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Agent',
      content: 'Are you sure you want to delete ${agent.name}?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirm == true) {
      await _deleteAgent(agent.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${agent.name} deleted')),
      );
    }
  }
}
