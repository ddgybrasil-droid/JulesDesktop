import 'package:flutter/material.dart';

// Stub: Main Kanban board widget showing task columns
class KanbanBoard extends StatelessWidget {
  const KanbanBoard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Text('Stub: Kanban Board (Queued, In Testing, Ready for PR, Completed)'),
      ),
    );
  }
}
