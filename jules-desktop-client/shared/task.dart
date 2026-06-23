// Stub: Shared task model for Dart
// Represents a task that is synchronized between frontend and backend.
// Note: In a real app, you'd use json_serializable or similar.

enum TaskStatus {
  queued,
  inTesting,
  readyForPr,
  completed,
  failed
}

class Task {
  final String id;
  final String prompt;
  final String repo;
  final String branch;
  final TaskStatus status;

  Task({
    required this.id,
    required this.prompt,
    required this.repo,
    required this.branch,
    required this.status,
  });

  // Stub function to deserialize from JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      repo: json['repo'] as String,
      branch: json['branch'] as String,
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }

  // Stub function to serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'repo': repo,
      'branch': branch,
      'status': status.name,
    };
  }
}
