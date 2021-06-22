import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';

/// Base widget for the different [ProfileHomePage] content widgets.
abstract class ProfileHomePageContentState<T extends StatefulWidget> extends State<T> {
  /// Stream that notifies changes in the total progress of the long tasks.
  // ignore: cancel_subscriptions
  StreamSubscription<double>? _longTasksProgressSubscription;

  /// Total progress of the long tasks.
  double? longTasksProgress;

  /// Whether there are pending updates to packs.
  late Future<bool> areUpdatesAvailable;

  @override
  void initState() {
    super.initState();

    areUpdatesAvailable = repository.packs.areUpdatesAvailable();

    _subscribeStreams();
  }

  /// Subscribe to the stream(s) this page uses.
  void _subscribeStreams() {
    this._longTasksProgressSubscription?.cancel();
    this._longTasksProgressSubscription = repository.longTasksProgressStream.listen((progress) {
      setState(() {
        this.longTasksProgress = (progress != -1) ? progress : null;
        _subscribeStreams();
        if (progress == -1) {
          areUpdatesAvailable = repository.packs.areUpdatesAvailable();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    this._longTasksProgressSubscription?.cancel();
  }

  /// Start the game.
  void play() {
    setState(() {
      repository.startGame();
    });
  }

  /// Update all the available updates.
  void updateAll() {
    setState(() {
      repository.packs.updateAllPacks();
    });
  }
}
