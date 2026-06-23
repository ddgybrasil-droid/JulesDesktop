import 'package:flutter/material.dart';

// Stub: State management for tasks.
// Will coordinate with IPC to send tasks and get their status.
class TaskProvider extends ChangeNotifier {
  // Placeholder dummy data
  List<String> get queuedTasks => ['Stub Task 1', 'Stub Task 2'];
  List<String> get inTestingTasks => ['Stub Task 3'];
  List<String> get readyForPrTasks => [];
  List<String> get completedTasks => ['Stub Task 4'];

  // Stub function to send a new task via IPC
  void sendTask(String prompt, String repo, String branch) {
    // Send IPC request to Rust backend
    print('Stub: sendTask($prompt, $repo, $branch)');
    notifyListeners();
  }

  // Stub function to get status via IPC
  void fetchTaskStatus(String taskId) {
    // Call Rust backend for status
    print('Stub: fetchTaskStatus($taskId)');
  }
}
