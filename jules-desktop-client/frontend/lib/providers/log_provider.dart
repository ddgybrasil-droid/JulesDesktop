import 'package:flutter/material.dart';
import 'dart:async';

// Stub: State management for execution logs.
// Will coordinate with IPC to receive streaming logs from the Jules CLI.
class LogProvider extends ChangeNotifier {
  final List<String> _logs = ['[System] Log stream initialized.'];
  Timer? _timer;

  List<String> get logs => _logs;

  // Stub function to start streaming logs for a task via IPC
  void startStreaming(String taskId) {
    // Send IPC command to Rust to start log stream
    print('Stub: startStreaming($taskId)');

    // Clear existing logs when starting a new stream
    _logs.clear();
    _logs.add('[System] Starting log stream for task $taskId...');
    notifyListeners();

    // Cancel any existing timer
    _timer?.cancel();

    // Setup mock LogProvider to feed fake stream logs
    int count = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      count++;
      appendLog('[INFO] Executing step $count for $taskId...');
      if (count >= 10) {
        appendLog('[SUCCESS] Task $taskId completed successfully.');
        timer.cancel();
      }
    });
  }

  // Stub function to append a log line (called when IPC event is received)
  void appendLog(String logLine) {
    _logs.add(logLine);
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
