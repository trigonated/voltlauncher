import 'package:flutter/material.dart';
import 'package:voltlauncher/model/objects/settings.dart';
import 'package:voltlauncher/model/repository/repository.dart';
import 'ui/voltlauncherapp.dart';

/// The data repository.
Repository repository = Repository();

/// Application settings
AppSettings get appSettings => repository.appSettings;

void main() {
  runApp(VoltLauncherApp());
}
