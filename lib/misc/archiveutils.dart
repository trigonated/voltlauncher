import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as path_lib;

/// Methods for dealing with zip archives.
abstract class ArchiveUtils {
  /// Extract the zip archive [file] to the [extractTo] directory.
  static Future<Archive> extractArchive({required File file, required Directory extractTo}) async {
    // Decode the archive
    final Uint8List bytes = await file.readAsBytes();
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    // Extract the contents of the Zip archive to the target directory
    for (final archiveItem in archive) {
      if (archiveItem.isFile) {
        // Item is a file
        File archiveItemFile = File(path_lib.join(extractTo.path, archiveItem.name));
        await archiveItemFile.create(recursive: true);
        await archiveItemFile.writeAsBytes((archiveItem.content as List<int>));
      } else {
        // Item is a directory
        Directory archiveItemDirectory = Directory(path_lib.join(extractTo.path, archiveItem.name));
        await archiveItemDirectory.create(recursive: true);
      }
    }
    return archive;
  }
}
