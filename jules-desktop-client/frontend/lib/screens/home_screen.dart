import 'package:flutter/material.dart';
import '../widgets/kanban_board.dart';
import '../widgets/task_creation_panel.dart';
import '../widgets/execution_log.dart';
import '../widgets/pro_status_widget.dart';

// Stub: Home screen containing the main UI layout
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          // Custom Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'HOME DASHBOARD',
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w900,
                    fontSize: 28.0,
                    letterSpacing: 2.0,
                    color: Colors.white,
                  ),
                ),
                const ProStatusWidget(),
              ],
            ),
          ),
          Expanded(
            child: Row(
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
          ),
        ],
      ),
    );
  }
}
