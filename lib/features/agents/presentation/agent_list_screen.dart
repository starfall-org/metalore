import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/storage/agent_repository.dart';
import '../../../core/models/ai_agent.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/item_card.dart';
import 'add_agent_screen.dart';
import 'agent_detailed_screen.dart';

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
        title: Text('agents.title'.tr()),
        actions: [
          AddAction(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAgentScreen()),
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
              message: 'agents.no_agents'.tr(),
              actionLabel: 'agents.add_new_agent'.tr(),
              onAction: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddAgentScreen(),
                  ),
                );
                if (result == true) {
                  _loadAgents();
                }
              },
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _agents.length,
              itemBuilder: (context, index) {
                final agent = _agents[index];
                return ItemCard(
                  title: agent.name,
                  subtitle: agent.config.systemPrompt,
                  icon: CircleAvatar(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primaryContainer,
                    child: Text(
                      agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                    ),
                  ),
                  onTap: () async {
                    // In "Agent list" selection mode: set as selected and pop
                    await _repository.setSelectedAgentId(agent.id);
                    if (!context.mounted) return;
                    Navigator.pop(context, true);
                  },
                  onView: () => _viewAgent(agent),
                  onEdit: () => _editAgent(agent),
                  onDelete: () => _confirmDelete(agent),
                );
              },
            ),
    );
  }

  void _viewAgent(AIAgent agent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgentDetailedScreen(agent: agent),
      ),
    );
    if (result == true) {
      _loadAgents();
    }
  }

  void _editAgent(AIAgent agent) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddAgentScreen(agent: agent)),
    );
    if (result == true) {
      _loadAgents();
    }
  }

  Future<void> _confirmDelete(AIAgent agent) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'common.delete'.tr(),
      content: 'agents.delete_confirm'.tr(args: [agent.name]),
      confirmLabel: 'common.delete'.tr(),
      isDestructive: true,
    );
    if (confirm == true) {
      await _deleteAgent(agent.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('agents.agent_deleted'.tr(args: [agent.name]))),
      );
    }
  }
}
