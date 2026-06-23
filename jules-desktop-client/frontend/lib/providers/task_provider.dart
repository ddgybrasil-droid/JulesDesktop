import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

enum TaskStatus {
  queued,
  inTesting,
  readyForPr,
  completed,
}

class Task {
  final String id;
  final String title;
  final String description;
  TaskStatus status;
  int timeElapsed; // in seconds

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.timeElapsed = 0,
  });
}

class TaskProvider extends ChangeNotifier {
  Timer? _timer;

  final List<Task> _tasks = [
    Task(
      id: '1',
      title: 'Update dependencies',
      description: 'Bump flutter and provider versions.',
      status: TaskStatus.queued,
    ),
    Task(
      id: '2',
      title: 'Fix styling issue',
      description: 'Header component is overflowing on small screens.',
      status: TaskStatus.queued,
    ),
    Task(
      id: '3',
      title: 'Implement drag and drop',
      description: 'Allow reordering items in the list view.',
      status: TaskStatus.inTesting,
      timeElapsed: 345,
    ),
    Task(
      id: '4',
      title: 'Refactor state management',
      description: 'Move away from setState to Provider.',
      status: TaskStatus.inTesting,
      timeElapsed: 1200,
    ),
    Task(
      id: '5',
      title: 'Add unit tests',
      description: 'Write tests for the new utility functions.',
      status: TaskStatus.readyForPr,
    ),
    Task(
      id: '6',
      title: 'Setup CI/CD',
      description: 'Configure GitHub Actions for automated builds.',
      status: TaskStatus.completed,
      timeElapsed: 5400,
    ),
  ];

  TaskProvider() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool shouldNotify = false;
      for (var task in _tasks) {
        if (task.status == TaskStatus.inTesting) {
          task.timeElapsed++;
          shouldNotify = true;
        }
      }
      if (shouldNotify) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<Task> get tasks => _tasks;

  List<Task> get queuedTasks => _tasks.where((t) => t.status == TaskStatus.queued).toList();
  List<Task> get inTestingTasks => _tasks.where((t) => t.status == TaskStatus.inTesting).toList();
  List<Task> get readyForPrTasks => _tasks.where((t) => t.status == TaskStatus.readyForPr).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.status == TaskStatus.completed).toList();

  void sendTask(String prompt, String repo, String branch) {
    final requestId = DateTime.now().millisecondsSinceEpoch.toString();

    // IPC call via stdio
    final request = {
      'id': requestId,
      'command': 'send_task',
      'payload': {
        'prompt': prompt,
        'repo': repo,
        'branch': branch,
      }
    };
    stdout.writeln(jsonEncode(request));

    final newTask = Task(
      id: requestId,
      title: prompt,
      description: 'Repository: $repo, Branch: $branch',
      status: TaskStatus.queued,
    );
    _tasks.add(newTask);
    notifyListeners();
  }

  void fetchTaskStatus(String taskId) {
    // Stub IPC call
    print('Stub: fetchTaskStatus($taskId)');
  }

  void updateTaskStatus(String taskId, TaskStatus newStatus) {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index].status = newStatus;
      notifyListeners();
    }
  }
}
