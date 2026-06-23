import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';
import 'techno_metric_header.dart';

// Stub: Terminal-like widget that displays streamed stdout from Rust
class ExecutionLog extends StatefulWidget {
  const ExecutionLog({Key? key}) : super(key: key);

  @override
  State<ExecutionLog> createState() => _ExecutionLogState();
}

class _ExecutionLogState extends State<ExecutionLog> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch for log updates
    final logs = context.watch<LogProvider>().logs;

    // After the build phase, scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TechnoMetricHeader(
            title: 'EXECUTION LOG',
            metric: logs.length.toString(),
            accentColor: Colors.orangeAccent,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: logs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Text(
                    logs[index],
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
