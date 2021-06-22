import 'dart:io';

import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/misc/longtask.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/repository/repository.dart';

/// [LongTask] that uninstalls a pack.
class UninstallPackLongTask extends LongTask {
  Pack pack;

  UninstallPackLongTask({required Repository repository, required this.pack}) : super() {
    this.id = generateId(this.pack);
  }

  /// Generate an unique id used to identify this task.
  static String generateId(Pack pack) => "pack_uninstall(${pack.name})";

  @override
  Future<void> doTask() async {
    // Delete the pack directory
    this.progress = 0;
    PacksDirectory packsDirectory = LocalDirectories.appData.installs.currentInstall.packs;
    await packsDirectory.pack(pack.name).directory.delete(recursive: true);

    // Delete the version file
    this.progress = 0.5;
    File versionFile = packsDirectory.versionFile(pack.name);
    if (await versionFile.exists()) {
      versionFile.delete();
    }

    // Done
    this.progress = 1;
    repository.local.clearCache();
    repository.packs.clearCache();
    repository.packs.notifyPacksChanged();
  }
}
