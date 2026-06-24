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
  final FocusNode _promptFocusNode = FocusNode();

  // Mock data for dropdowns
  final List<String> _repositories = ['jules-desktop-client', 'jules-backend', 'jules-frontend'];
  final List<String> _branches = ['main', 'develop', 'feature/new-ui'];

  String? _selectedRepo;
  String? _selectedBranch;

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _selectedRepo = _repositories.first;
    _selectedBranch = _branches.first;

    _promptController.addListener(_onPromptChanged);
    _promptFocusNode.addListener(() {
      if (!_promptFocusNode.hasFocus) {
        _hideOverlay();
      }
    });
  }

  void _onPromptChanged() {
    final text = _promptController.text;
    final selection = _promptController.selection;

    if (selection.baseOffset == -1) return;

    final beforeCursor = text.substring(0, selection.baseOffset);
    final words = beforeCursor.split(RegExp(r'\s+'));
    final currentWord = words.isNotEmpty ? words.last : '';

    if (currentWord.startsWith('/')) {
      _showSlashCommandOverlay(currentWord);
    } else if (currentWord.startsWith('@')) {
      _showMentionOverlay(currentWord);
    } else {
      _hideOverlay();
    }
  }

  void _showSlashCommandOverlay(String query) {
    _hideOverlay();

    final commands = [
      '/test [module]',
      '/trim [dir]',
      '/mask',
      '/map',
      '/preview',
      '/fix [log]',
      '/clean'
    ].where((cmd) => cmd.startsWith(query)).toList();

    if (commands.isEmpty) return;

    _overlayEntry = _createOverlayEntry(commands, (String value) {
      _insertText(value.split(' ').first, query.length);
    });
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _showMentionOverlay(String query) {
    _hideOverlay();

    final files = [
      '@frontend/lib/main.dart',
      '@backend/src/main.rs',
      '@shared/models.dart',
      '@README.md'
    ].where((f) => f.startsWith(query)).toList();

    if (files.isEmpty) return;

    _overlayEntry = _createOverlayEntry(files, (String value) {
      _insertText(value, query.length);
    });
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _insertText(String text, int replaceLength) {
    final currentText = _promptController.text;
    final selection = _promptController.selection;

    final newText = currentText.replaceRange(
      selection.baseOffset - replaceLength,
      selection.baseOffset,
      '$text '
    );

    _promptController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.baseOffset - replaceLength + text.length + 1
      ),
    );
    _hideOverlay();
    _promptFocusNode.requestFocus();
  }

  OverlayEntry _createOverlayEntry(List<String> items, Function(String) onSelect) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0.0, 100.0), // Approximate offset below text field
          child: Material(
            elevation: 8.0,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E).withValues(alpha: 0.95),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8.0),
              ),
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      items[index],
                      style: const TextStyle(color: Colors.white70),
                    ),
                    onTap: () => onSelect(items[index]),
                    hoverColor: Colors.blueAccent.withValues(alpha: 0.2),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
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
      color: const Color(0xFF181818),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Creation Panel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: _promptController,
              focusNode: _promptFocusNode,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Prompt',
                labelStyle: const TextStyle(color: Colors.white70),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white30),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
                hintText: 'Type @ to attach files or / for commands...',
                hintStyle: const TextStyle(color: Colors.white38),
                fillColor: const Color(0xFF1E1E1E),
                filled: true,
              ),
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
