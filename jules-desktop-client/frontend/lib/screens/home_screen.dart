import 'package:flutter/material.dart';
import '../widgets/kanban_board.dart';
import '../widgets/task_creation_panel.dart';
import '../widgets/execution_log.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/right_sidebar.dart';
import '../widgets/tools_hub_panel.dart';

// Stub: Home screen containing the main UI layout
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLeftSidebarCollapsed = false;
  bool _isRightSidebarCollapsed = true;
  bool _showToolsHub = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Dark brutalist background
      body: SafeArea(
        child: Row(
          children: [
            LeftSidebar(
              isCollapsed: _isLeftSidebarCollapsed,
              onToggle: () {
                setState(() {
                  _isLeftSidebarCollapsed = !_isLeftSidebarCollapsed;
                });
              },
              onNavSelected: (String label) {
                setState(() {
                  if (label == 'Skills & Tools Hub') {
                    _showToolsHub = true;
                  } else {
                    _showToolsHub = false;
                  }
                });
              },
            ),
            Expanded(
              child: Column(
                children: [
                  const TaskCreationPanel(),
                  Expanded(
                    child: _showToolsHub
                    ? const ToolsHubPanel()
                    : Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: KanbanBoard(),
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
            ),
            RightSidebar(
              isCollapsed: _isRightSidebarCollapsed,
              onToggle: () {
                setState(() {
                  _isRightSidebarCollapsed = !_isRightSidebarCollapsed;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
