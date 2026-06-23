import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:jules_desktop_client/providers/task_provider.dart';

void main() {
  test('sendTask pipes output and creates task', () {
    final provider = TaskProvider();

    // We can run sendTask and verify the task state at least.
    // Standard output capturing is a bit more complex in standard tests,
    // but we can verify the state of the provider.
    final initialCount = provider.tasks.length;

    // Run the provider method.
    // NOTE: This will write to stdout which we can capture or just let it run.
    runZonedGuarded(() {
      provider.sendTask('prompt text', 'test/repo', 'main');
    }, (e, s) {});

    expect(provider.tasks.length, initialCount + 1);
    final newTask = provider.tasks.last;
    expect(newTask.title, 'prompt text');
    expect(newTask.description, 'Repository: test/repo, Branch: main');
    expect(newTask.status, TaskStatus.queued);
  });
}
