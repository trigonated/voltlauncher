import 'dart:io';

/// Methods for opening the file explorer.
abstract class ShowInFileExplorer {
  /// Show [directory] in the OS's file explorer.
  static void showDirectoryInFileExplorer(Directory directory) {
    if (Platform.isWindows) {
      Process.run("start", [directory.path], runInShell: true);
    } else if (Platform.isMacOS) {
      Process.run("open", [directory.path], runInShell: true);
    } else if (Platform.isLinux) {
      Process.run("xdg-open", [directory.path], runInShell: true);
    } else {
      // Do nothing
    }
  }
}
