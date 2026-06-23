import 'package:flutter/material.dart';
import '../widgets/kanban_board.dart';
import '../widgets/task_creation_panel.dart';
import '../widgets/execution_log.dart';

// Stub: Home screen containing the main UI layout
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF0A0A0A),
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: const [
                TaskCreationPanel(),
                Expanded(child: KanbanBoard()),
              ],
            ),
          ),
          const Expanded(
            flex: 1,
            child: ExecutionLog(),
          ),
        ],
      ),
    );
  }
}
