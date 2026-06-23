import 'package:flutter/material.dart';

// Stub: Terminal-like widget that displays streamed stdout from Rust
class ExecutionLog extends StatelessWidget {
  const ExecutionLog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8.0),
      child: const Text(
        'Stub: Execution Log (Terminal stdout placeholder)',
        style: TextStyle(color: Colors.green, fontFamily: 'monospace'),
      ),
    );
  }
}
