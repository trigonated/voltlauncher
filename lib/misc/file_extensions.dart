import 'dart:io';

/// Extensions for the [File] class.
extension FileExtension on File {
  /// Delete the file, doing nothing if the file does not exist.
  Future<FileSystemEntity?> deleteIfExists({bool recursive = false}) async {
    if (await this.exists()) {
      return this.delete();
    } else {
      return null;
    }
  }

  /// Delete the file, doing nothing if the file does not exist.
  void deleteIfExistsSync({bool recursive = false}) {
    if (this.existsSync()) {
      this.deleteSync();
    }
  }
}
