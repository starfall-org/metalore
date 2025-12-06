import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../features/agents/domain/agent.dart';

class AgentRepository {
  static const String _storageKey = 'agents';
  static const String _selectedKey = 'selected_agent_id';
  final SharedPreferences _prefs;

  AgentRepository(this._prefs);

  static Future<AgentRepository> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AgentRepository(prefs);
  }

  List<Agent> getAgents() {
    final List<String>? agentsJson = _prefs.getStringList(_storageKey);
    if (agentsJson == null || agentsJson.isEmpty) {
      final defaultAgent = _createDefaultAgent();
      // Persist the default so other features see consistent state
      _prefs.setStringList(_storageKey, [defaultAgent.toJsonString()]);
      // Ensure a valid selection exists
      _prefs.setString(_selectedKey, defaultAgent.id);
      return [defaultAgent];
    }
    return agentsJson.map((str) => Agent.fromJsonString(str)).toList();
  }

  Future<void> addAgent(Agent agent) async {
    final agents = getAgents();
    agents.add(agent);
    await _saveAgents(agents);
    // If no selection yet, select the newly added agent by default
    _prefs.setString(_selectedKey, getSelectedAgentId() ?? agent.id);
  }

  Future<void> deleteAgent(String id) async {
    final agents = getAgents();
    agents.removeWhere((a) => a.id == id);
    await _saveAgents(agents);

    // Maintain a valid selection after deletion
    final selectedId = getSelectedAgentId();
    if (selectedId == id) {
      if (agents.isNotEmpty) {
        _prefs.setString(_selectedKey, agents.first.id);
      } else {
        _prefs.remove(_selectedKey);
      }
    }
  }

  Future<void> _saveAgents(List<Agent> agents) async {
    final List<String> agentsJson =
        agents.map((a) => a.toJsonString()).toList();
    await _prefs.setStringList(_storageKey, agentsJson);
  }

  // --- Selection helpers ---

  String? getSelectedAgentId() => _prefs.getString(_selectedKey);

  Future<void> setSelectedAgentId(String id) async {
    await _prefs.setString(_selectedKey, id);
  }

  Future<Agent> getOrInitSelectedAgent() async {
    final agents = getAgents();
    final selectedId = getSelectedAgentId();
    Agent selected;
    if (selectedId != null) {
      selected = agents.firstWhere(
        (a) => a.id == selectedId,
        orElse: () => agents.first,
      );
    } else {
      selected = agents.first;
      await setSelectedAgentId(selected.id);
    }
    return selected;
  }

  Agent _createDefaultAgent() {
    return Agent(
      id: const Uuid().v4(),
      name: 'Default Agent',
      systemPrompt: '',
    );
  }
}
