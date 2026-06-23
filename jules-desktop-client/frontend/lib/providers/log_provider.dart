import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';

class ParsedLog {
  final String taskId;
  final String line;

  ParsedLog({required this.taskId, required this.line});
}

void _logParserIsolate(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) {
    if (message is String) {
      try {
        final decoded = jsonDecode(message);
        if (decoded is Map<String, dynamic> && decoded['event'] == 'log_stream') {
          final payload = decoded['payload'];
          if (payload is Map<String, dynamic>) {
            final taskId = payload['task_id'];
            final line = payload['line'];
            if (taskId is String && line is String) {
              sendPort.send(ParsedLog(taskId: taskId, line: line));
            }
          }
        }
      } catch (e) {
        // Ignore parse errors for non-JSON or malformed lines
      }
    }
  });
}

class LogProvider extends ChangeNotifier {
  // Stub fallback path for the Rust executable
  static const String rustExecutablePath = "./backend_binary";

  final List<String> _logs = ['[System] Log stream initialized.'];
  String? _activeTaskId;

  Isolate? _parserIsolate;
  SendPort? _parserSendPort;
  ReceivePort? _receivePort;

  StreamSubscription<String>? _stdoutSubscription;
  final List<String> _pendingLines = [];

  LogProvider() {
    _initIsolate();
  }

  List<String> get logs => _logs;

  Future<void> _initIsolate() async {
    _receivePort = ReceivePort();
    _parserIsolate = await Isolate.spawn(_logParserIsolate, _receivePort!.sendPort);

    _receivePort!.listen((message) {
      if (message is SendPort) {
        _parserSendPort = message;
        // Flush any buffered lines
        for (final line in _pendingLines) {
          _parserSendPort?.send(line);
        }
        _pendingLines.clear();
      } else if (message is ParsedLog) {
        _handleParsedLog(message);
      }
    });
  }

  void _handleParsedLog(ParsedLog parsedLog) {
    if (_activeTaskId != null && parsedLog.taskId == _activeTaskId) {
      _logs.add(parsedLog.line);
      notifyListeners();
    }
  }

  void attachStdout(Stream<List<int>> stdout) {
    _stdoutSubscription?.cancel();
    _stdoutSubscription = stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (_parserSendPort == null) {
        _pendingLines.add(line);
      } else {
        _parserSendPort?.send(line);
      }
    });
  }

  void startStreaming(String taskId) {
    // Send IPC command to Rust to start log stream
    print('Stub: startStreaming($taskId)');

    _activeTaskId = taskId;
    _logs.clear();
    _logs.add('[System] Starting log stream for task $taskId...');
    notifyListeners();
  }

  void appendLog(String logLine) {
    _logs.add(logLine);
    notifyListeners();
  }

  @override
  void dispose() {
    _stdoutSubscription?.cancel();
    _receivePort?.close();
    _parserIsolate?.kill();
    super.dispose();
  }
}
