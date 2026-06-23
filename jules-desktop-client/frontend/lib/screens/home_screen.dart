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
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: const [
                  TaskCreationPanel(),
                  SizedBox(height: 16.0),
                  Expanded(child: KanbanBoard()),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            const Expanded(
              flex: 1,
              child: ExecutionLog(),
            ),
          ],
        ),
      ),
    );
  }
}
