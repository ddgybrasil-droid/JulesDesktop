import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF121212), // Dark overall background
      padding: const EdgeInsets.all(16.0),
      child: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildColumn('Queued', taskProvider.queuedTasks, Colors.grey.shade400),
              const SizedBox(width: 16.0),
              _buildColumn('In Testing', taskProvider.inTestingTasks, Colors.purpleAccent),
              const SizedBox(width: 16.0),
              _buildColumn('Ready for PR', taskProvider.readyForPrTasks, Colors.blueAccent),
              const SizedBox(width: 16.0),
              _buildColumn('Completed', taskProvider.completedTasks, Colors.greenAccent),
            ],
          );
        },
      ),
    );
  }

  Widget _buildColumn(String title, List<Task> tasks, Color accentColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0),
                topRight: Radius.circular(8.0),
              ),
              border: Border(
                top: BorderSide(color: accentColor, width: 2.0),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12.0,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column Body
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF181818),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(12.0),
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(task: tasks[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
