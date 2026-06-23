import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  String _formatDuration(int totalSeconds) {
    if (totalSeconds == 0) return '';
    final duration = Duration(seconds: totalSeconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Color _getStatusColor() {
    switch (task.status) {
      case TaskStatus.queued:
        return Colors.grey.shade400;
      case TaskStatus.inTesting:
        return Colors.purpleAccent; // Neon purple
      case TaskStatus.readyForPr:
        return Colors.blueAccent; // Neon blue
      case TaskStatus.completed:
        return Colors.greenAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final isTesting = task.status == TaskStatus.inTesting;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.5),
                width: 1.0, // Thinner border
              ),
              boxShadow: isTesting ? [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.3),
                  blurRadius: 8.0,
                  spreadRadius: 1.0,
                )
              ] : [],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      if (task.timeElapsed > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isTesting) ...[
                                Icon(
                                  Icons.timer,
                                  size: 12.0,
                                  color: statusColor,
                                ),
                                const SizedBox(width: 4.0),
                              ],
                              Text(
                                _formatDuration(task.timeElapsed),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12.0,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    task.description,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.0,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: ${task.id}',
                        style: TextStyle(
                          color: Colors.white30,
                          fontSize: 10.0,
                        ),
                      ),
                      Container(
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.5),
                              blurRadius: 4.0,
                              spreadRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
