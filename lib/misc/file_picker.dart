import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

/// Methods to show the file picker.
///
/// This is a wrapper for the `file_selector` library.
abstract class FilePicker {
  /// Show a file picker for `zip` archives.
  static Future<File?> showArchivePicker() async {
    final typeGroup = XTypeGroup(
      label: 'Zip archives',
      extensions: ['zip'],
    );
    final file = await FileSelectorPlatform.instance.openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      return File(file.path);
    } else {
      return null;
    }
  }

  /// Show a file picker for `png` images.
  static Future<File?> showImagePicker() async {
    final typeGroup = XTypeGroup(
      label: 'PNG images',
      extensions: ['png'],
    );
    final file = await FileSelectorPlatform.instance.openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      return File(file.path);
    } else {
      return null;
    }
  }
}
