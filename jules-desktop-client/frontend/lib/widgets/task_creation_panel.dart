import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/log_provider.dart';
import 'secure_env_masker_card.dart';

// Stub: Form panel to create and send a new task
class TaskCreationPanel extends StatefulWidget {
  const TaskCreationPanel({Key? key}) : super(key: key);

  @override
  State<TaskCreationPanel> createState() => _TaskCreationPanelState();
}

class _TaskCreationPanelState extends State<TaskCreationPanel> {
  final _promptController = TextEditingController();

  // Mock data for dropdowns
  final List<String> _repositories = ['jules-desktop-client', 'jules-backend', 'jules-frontend'];
  final List<String> _branches = ['main', 'develop', 'feature/new-ui'];

  String? _selectedRepo;
  String? _selectedBranch;

  @override
  void initState() {
    super.initState();
    _selectedRepo = _repositories.first;
    _selectedBranch = _branches.first;
  }

  void _handleSend() {
    final prompt = _promptController.text;
    final repo = _selectedRepo ?? '';
    final branch = _selectedBranch ?? '';

    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt')),
      );
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final logProvider = context.read<LogProvider>();

    // Call task provider
    taskProvider.sendTask(prompt, repo, branch);

    // Trigger mock log stream for demonstration
    final mockTaskId = 'task-${DateTime.now().millisecondsSinceEpoch}';
    logProvider.startStreaming(mockTaskId);

    // Clear prompt
    _promptController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Creation Panel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const SecureEnvMaskerCard(),
          const SizedBox(height: 16),
          TextField(
            controller: _promptController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Prompt',
              border: OutlineInputBorder(),
              hintText: 'Enter your task prompt here...',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedRepo,
                  isExpanded: true,
                  hint: const Text('Repository'),
                  items: _repositories.map((repo) {
                    return DropdownMenuItem(value: repo, child: Text(repo));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedRepo = val;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedBranch,
                  isExpanded: true,
                  hint: const Text('Branch'),
                  items: _branches.map((branch) {
                    return DropdownMenuItem(value: branch, child: Text(branch));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedBranch = val;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _handleSend,
              icon: const Icon(Icons.send),
              label: const Text('Send Task'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
