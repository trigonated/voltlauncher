import 'dart:io';

import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/archiveutils.dart';
import 'package:voltlauncher/misc/downloadutils.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/misc/longtask.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/repository/repository.dart';
import 'package:path/path.dart' as path_lib;
import 'package:io/io.dart' as io;
import 'package:crypto/crypto.dart';

/// [LongTask] that updates a pack.
class UpdatePackLongTask extends LongTask {
  Pack pack;

  UpdatePackLongTask({required Repository repository, required this.pack}) : super() {
    this.id = generateId(this.pack);
  }

  /// Generate an unique id used to identify this task.
  static String generateId(Pack pack) => "pack_update(${pack.name})";

  @override
  Future<void> doTask() async {
    // Used for testing
    // for (var i = 0; i < 100; i++) {
    //   this.progress += 1.0 / 100.0;
    //   await new Future.delayed(const Duration(milliseconds: 100));
    // }

    if (this.pack.downloadUrl != null) {
      // Download the pack
      File? downloadedArchive = await _downloadArchive(
        downloadUrl: this.pack.downloadUrl!,
        filename: "${this.pack.name}.zip",
        checksum: this.pack.checksum,
        percentageOfTotal: 0.9,
      );
      if (downloadedArchive == null) return;

      // Extract the downloaded archive
      Directory? extractedArchive = await _extractArchive(
        archive: downloadedArchive,
        outputDirectoryName: this.pack.name,
      );
      if (extractedArchive == null) return;

      // Copy the extracted archive to the install's packs directory
      this.progress = 0.95;
      bool installed = await _installArchive(
        extractedPack: extractedArchive,
        packVersion: this.pack.latestVersion,
      );
      if (!installed) return;

      // Remove the downloaded files from the cache
      this.progress = 0.99;
      await downloadedArchive.delete();
      await extractedArchive.delete(recursive: true);

      // Done
      this.progress = 1;
      repository.local.clearCache();
      repository.packs.clearCache();
      repository.packs.notifyPacksChanged();
    }
  }

  /// Download an archive from [downloadUrl], saving it as [filename] in the downloads directory.
  /// If [checksum] is non-null, the checksum is compared after the download.
  ///
  /// [percentageOfTotal] represents how much of the total task progress this download represents.
  Future<File?> _downloadArchive({required String downloadUrl, required String filename, required String? checksum, required double percentageOfTotal}) async {
    await LocalDirectories.appData.cache.downloads.directory.create(recursive: true);
    File file = LocalDirectories.appData.cache.downloads.file(filename);
    // Download the file
    bool success = await DownloadUtils.downloadFile(
        url: this.pack.downloadUrl!,
        downloadTo: file,
        onProgressChanged: (progress) {
          this.progress = progress * percentageOfTotal;
        });
    if (success) {
      // Do the checksum
      if (checksum != null) {
        String fileChecksum = sha256.convert(await file.readAsBytes()).toString();
        print("Checksum: " + checksum);
        print("File checksum: " + fileChecksum);
        if (fileChecksum != checksum) {
          return null;
        }
      }
      return file;
    } else {
      return null;
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
