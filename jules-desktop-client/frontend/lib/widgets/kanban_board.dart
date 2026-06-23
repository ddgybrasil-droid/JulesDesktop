import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import 'task_card.dart';

class KanbanBoard extends StatelessWidget {
  const KanbanBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Make overall background transparent
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Column Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1.0),
                      top: BorderSide(color: accentColor, width: 2.0),
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
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      return TaskCard(task: tasks[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
