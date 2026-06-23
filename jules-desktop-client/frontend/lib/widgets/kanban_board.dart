import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Transparent overall background
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
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          border: Border.all(color: Colors.white24, width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Column Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white24, width: 1.0),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
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
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
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
      ),
    );
  }
}
