import 'dart:io';

import 'package:io/io.dart' as io;
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/archiveutils.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/misc/longtask.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/repository/repository.dart';
import 'package:path/path.dart' as path_lib;

/// [LongTask] that installs a pack from a local archive.
class InstallLocalPackLongTask extends LongTask {
  File archiveFile;

  InstallLocalPackLongTask({required Repository repository, required this.archiveFile}) : super() {
    this.id = generateId(this.archiveFile);
  }

  /// Generate an unique id used to identify this task.
  static String generateId(File archiveFile) => "localpack_install(${_generatePackName(archiveFile)})";

  /// Generates a name for the pack from the archive's filename.
  static String _generatePackName(File archiveFile) => path_lib.basenameWithoutExtension(archiveFile.path).toLowerCase();

  @override
  Future<void> doTask() async {
    final String packName = _generatePackName(this.archiveFile);

    // Extract the archive
    this.progress = 0.5;
    Directory? extractedArchive = await _extractArchive(
      archive: this.archiveFile,
      outputDirectoryName: packName,
    );
    if (extractedArchive == null) return;

    // Copy the extracted archive to the install's packs directory
    this.progress = 0.95;
    bool installed = await _installArchive(
      extractedPack: extractedArchive,
      packVersion: null,
    );
    if (!installed) return;

    // Done
    this.progress = 1;
    repository.packs.notifyPacksChanged();
    // Enable the pack on the current profile
    Pack? pack = await repository.packs.fetchPack(refresh: true, name: packName);
    if (pack != null) {
      repository.currentProfile?.enablePack(pack);
    }
  }

  /// Extract the [archive] into a directory named [outputDirectoryName] inside the downloads cache directory.
  Future<Directory?> _extractArchive({required File archive, required String outputDirectoryName}) async {
    Directory outputDirectory = Directory(path_lib.join(LocalDirectories.appData.cache.downloads.directory.path, outputDirectoryName));
    await ArchiveUtils.extractArchive(file: archive, extractTo: outputDirectory);
    return outputDirectory;
  }

  /// Install an extracted archive. A version file will be created if [packVersion] is provided.
  Future<bool> _installArchive({required Directory extractedPack, required String? packVersion}) async {
    final String packName = path_lib.basename(extractedPack.path);
    PacksDirectory packsDirectory = LocalDirectories.appData.installs.currentInstall.packs;
    PackDirectory packDirectory = packsDirectory.pack(packName);
    // Delete the pack if it exists
    if (await packDirectory.directory.exists()) {
      await packDirectory.directory.delete(recursive: true);
    }
    // Copy the extracted pack's contents into the packs directory
    await io.copyPath(extractedPack.path, packDirectory.directory.path);
    // Create the version file
    if (packVersion != null) {
      await packsDirectory.versionFile(packName).writeAsString(packVersion);
    }
    return true;
  }
}
