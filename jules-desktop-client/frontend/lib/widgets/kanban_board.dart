import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';
import 'techno_metric_header.dart';

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
          TechnoMetricHeader(
            title: title,
            metric: tasks.length.toString(),
            accentColor: accentColor,
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
