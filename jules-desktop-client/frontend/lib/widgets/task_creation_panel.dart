import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/log_provider.dart';

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
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Creation Panel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _promptController,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Prompt',
                    labelStyle: const TextStyle(color: Colors.white70),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: 'Enter your task prompt here...',
                    hintStyle: const TextStyle(color: Colors.white30),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedRepo,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E1E1E),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        hint: const Text('Repository', style: TextStyle(color: Colors.white70)),
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
                        dropdownColor: const Color(0xFF1E1E1E),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        hint: const Text('Branch', style: TextStyle(color: Colors.white70)),
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
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }
}
