import 'package:flutter/material.dart';

// Stub: Form panel to create and send a new task
class TaskCreationPanel extends StatelessWidget {
  const TaskCreationPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Stub: Task Creation Panel'),
          TextField(decoration: InputDecoration(labelText: 'Prompt')),
          TextField(decoration: InputDecoration(labelText: 'Repository')),
          TextField(decoration: InputDecoration(labelText: 'Branch')),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: null, // Stub: Call taskProvider.sendTask()
            child: Text('Send'),
          )
        ],
      ),
    );
  }
}
