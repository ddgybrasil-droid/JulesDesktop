import 'package:flutter/material.dart';

// Stub: State management for execution logs.
// Will coordinate with IPC to receive streaming logs from the Jules CLI.
class LogProvider extends ChangeNotifier {
  final List<String> _logs = ['[System] Log stream initialized.'];

  List<String> get logs => _logs;

  // Stub function to start streaming logs for a task via IPC
  void startStreaming(String taskId) {
    // Send IPC command to Rust to start log stream
    print('Stub: startStreaming($taskId)');
  }

  // Stub function to append a log line (called when IPC event is received)
  void appendLog(String logLine) {
    _logs.add(logLine);
    notifyListeners();
  }
}
