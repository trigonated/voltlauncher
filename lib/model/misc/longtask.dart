import 'dart:async';

import 'package:voltlauncher/main.dart';

/// Represents a task that may take a significant time to complete.
///
/// These tasks' progress may be shown on the UI in the form of a progress bar.
abstract class LongTask {
  /// An unique id for the task.
  /// Tasks with repeated ids don't start (only a single task with a certain id can be running).
  /// [LongTask] classes usually have a static [generateId] method to generate this.
  late String id;

  /// The controller for the stream of this task's [progress].
  late StreamController<double> _progressStreamController;

  /// The stream of this task's [progress].
  late Stream<double> progressStream;

  /// The progress of this task. Values range from 0 (0%) to 1 (100%).
  double _progress = 0;

  /// The progress of this task. Values range from 0 (0%) to 1 (100%).
  double get progress => _progress;

  /// The progress of this task. Values range from 0 (0%) to 1 (100%).
  set progress(double value) {
    this._progress = value;
    this._progressStreamController.add(value);
    repository.notifyLongTasksProgressChanged();
  }

  LongTask() {
    this._progressStreamController = StreamController<double>.broadcast();
    this.progressStream = this._progressStreamController.stream;
  }

  /// Do whatever this [LongTask] is meant to do.
  ///
  /// Use [progress] to update the progress of this task, ideally ending with 100% progress.
  Future<void> doTask();

  void start() async {
    // Cancel if this task already existed
    if (repository.hasLongTask(this.id)) {
      return;
    }
    // Start the task
    repository.longTasks.add(this);
    this.progress = 0;
    repository.notifyLongTasksChanged();
    await doTask();
    repository.longTasks.remove(this);
    repository.notifyLongTasksChanged();
  }
}
