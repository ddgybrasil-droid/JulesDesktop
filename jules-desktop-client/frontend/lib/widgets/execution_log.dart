import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/log_provider.dart';

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
      margin: const EdgeInsets.all(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            padding: const EdgeInsets.all(8.0),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Execution Log',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Divider(color: Colors.white.withValues(alpha: 0.2)),
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
                            color: Colors.greenAccent,
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
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
