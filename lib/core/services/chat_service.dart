import '../models/mcp/mcp_server.dart';
import '../storage/mcp_repository.dart';
import '../storage/provider_repository.dart';
import '../models/ai_agent.dart';
import '../models/chat/message.dart';
import '../models/provider.dart';

class ChatService {
  static Future<void> generateReply({
    required String userText,
    required List<ChatMessage> history,
    required AIAgent agent,
    required String providerName,
    required String modelName,
  }) async {
    final providerRepo = await ProviderRepository.init();
    final providers = providerRepo.getProviders();
    if (providers.isEmpty) {
      throw Exception(
        'No provider configured. Please add a provider in Settings > Providers.',
      );
    }

    Provider provider = providers.where((p) => p.name == providerName).first;
    final model = provider.models.where((m) => m.name == modelName).first;

    try {
      final messagesWithCurrent = [
        ...history,
        ChatMessage(
          id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.user,
          content: userText,
          timestamp: DateTime.now(),
        ),
      ];

      final mcpRepository = await MCPRepository.init();
      final mcpServers = agent.activeMCPServerIds
          .map((id) => mcpRepository.getItem(id))
          .whereType<MCPServer>() // Filter out nulls
          .toList();
    } catch (e) {
      throw Exception('Failed to generate response: $e');
    }
  }
}
