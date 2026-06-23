import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'dart:io';
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
  bool _isDragging = false;

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

    if (taskProvider.droppedAssets.isNotEmpty) {
      taskProvider.syncLocalContext(taskProvider.droppedAssets, branch);
    }

    // Call task provider
    taskProvider.sendTask(prompt, repo, branch);

    // Trigger mock log stream for demonstration
    final mockTaskId = 'task-${DateTime.now().millisecondsSinceEpoch}';
    logProvider.startStreaming(mockTaskId);

    // Clear prompt
    _promptController.clear();
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Widget _buildAssetCapsule(String path, TaskProvider provider) {
    final file = File(path);
    int size = 0;
    try {
      if (file.existsSync()) {
        size = file.lengthSync();
      } else {
        // Might be a directory
        final dir = Directory(path);
        if (dir.existsSync()) {
           // We'll leave size 0 for directories to keep it simple, or mock it
        }
      }
    } catch (e) {
      // Ignore errors for permissions etc
    }

    final isDir = FileSystemEntity.isDirectorySync(path);
    final icon = isDir ? Icons.folder : Icons.insert_drive_file;
    final name = path.split(Platform.pathSeparator).last;

    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          if (!isDir && size > 0) ...[
            const SizedBox(width: 8),
            Text(
              _formatSize(size),
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
          const SizedBox(width: 8),
          InkWell(
            onTap: () => provider.removeAsset(path),
            child: const Icon(Icons.close, size: 16, color: Colors.redAccent),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();

    return DropTarget(
      onDragDone: (detail) {
        final paths = detail.files.map((f) => f.path).toList();
        taskProvider.addAssets(paths);
      },
      onDragEntered: (detail) {
        setState(() {
          _isDragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _isDragging = false;
        });
      },
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(16.0),
          dashPattern: const <double>[8, 8],
          color: _isDragging ? Colors.cyanAccent : Colors.transparent,
          strokeWidth: 2,
          padding: EdgeInsets.zero,
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A), // Deep black background
            border: Border.all(color: Colors.white24, width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Creation Panel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _promptController,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Prompt',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  hintText: 'Enter your task prompt here...',
                  hintStyle: TextStyle(color: Colors.white38),
                ),
              ),
              if (taskProvider.droppedAssets.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  children: taskProvider.droppedAssets
                      .map((path) => _buildAssetCapsule(path, taskProvider))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedRepo,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E1E1E),
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white24, width: 1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedBranch,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1E1E1E),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _handleSend,
                  icon: const Icon(Icons.send, color: Colors.black),
                  label: const Text('Send Task', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              )
            ],
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
