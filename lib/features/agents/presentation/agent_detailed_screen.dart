import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../core/models/ai_agent.dart';
import '../../../core/storage/agent_repository.dart';
import 'add_agent_screen.dart';

class AgentDetailedScreen extends StatelessWidget {
  final AIAgent agent;

  const AgentDetailedScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('agents.agent_details'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'agents.edit'.tr(),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAgentScreen(agent: agent),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Theme.of(context).colorScheme.error,
            tooltip: 'agents.delete'.tr(),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Avatar and Name
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text(
                    agent.name.isNotEmpty ? agent.name[0].toUpperCase() : 'A',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${agent.id.substring(0, 8)}...',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // System Prompt Section
            _buildSectionHeader(
              context,
              'agents.system_prompt'.tr(),
              Icons.psychology_outlined,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                agent.config.systemPrompt.isNotEmpty
                    ? agent.config.systemPrompt
                    : 'No system prompt configured.',
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 32),

            // Parameters Grid
            _buildSectionHeader(context, 'agents.parameters'.tr(), Icons.tune),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildInfoCard(
                  context,
                  'agents.temperature'.tr(),
                  agent.config.temperature?.toString() ?? 'Default',
                ),
                _buildInfoCard(
                  context,
                  'agents.top_p'.tr(),
                  agent.config.topP?.toString() ?? 'Default',
                ),
                _buildInfoCard(
                  context,
                  'agents.top_k'.tr(),
                  agent.config.topK?.toString() ?? 'Default',
                ),
                _buildInfoCard(
                  context,
                  'Stream',
                  agent.config.enableStream ? 'ON' : 'OFF',
                ),
                _buildInfoCard(
                  context,
                  'agents.context_window'.tr(),
                  agent.config.contextWindow.toString(),
                ),
                _buildInfoCard(
                  context,
                  'agents.max_tokens'.tr(),
                  agent.config.maxTokens.toString(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoCard(
              context,
              'agents.conversation_length'.tr(),
              agent.config.conversationLength.toString(),
            ),

            const SizedBox(height: 32),

            // Persistence
            if (agent.persistChatSelection != null) ...[
              _buildSectionHeader(
                context,
                'agents.persist_section_title'.tr(),
                Icons.save_outlined,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  agent.persistChatSelection!
                      ? Icons.check_circle
                      : Icons.cancel,
                  color: agent.persistChatSelection!
                      ? Colors.green
                      : Colors.red,
                ),
                title: Text(
                  agent.persistChatSelection!
                      ? 'agents.persist_force_on'.tr()
                      : 'agents.persist_force_off'.tr(),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // MCP Servers
            if (agent.activeMCPServerIds.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'agents.active_mcp_servers'.tr(),
                Icons.hub_outlined,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: agent.activeMCPServerIds
                    .map(
                      (id) => Chip(
                        label: Text(
                          id.substring(0, 8),
                        ), // Ideally show server name
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.secondaryContainer,
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('agents.delete'.tr()),
        content: Text('Are you sure you want to delete ${agent.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('agents.cancel'.tr()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text('agents.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = await AgentRepository.init();
      await repo.deleteAgent(agent.id);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    }
  }
}
