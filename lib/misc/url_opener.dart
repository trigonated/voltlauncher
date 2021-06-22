import 'dart:io';

/// Methods for opening urls in the browser.
abstract class UrlOpener {
  /// Open [url] in the OS's default browser.
  static void openUrl(String url) {
    if (Platform.isWindows) {
      Process.run("start", [url], runInShell: true);
    } else if (Platform.isMacOS) {
      Process.run("open", [url], runInShell: true);
    } else if (Platform.isLinux) {
      Process.run("xdg-open", [url], runInShell: true);
    } else {
      // Do nothing
    }
  }
}
