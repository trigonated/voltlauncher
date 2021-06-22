import 'dart:io';
import 'dart:convert';

/// Parser for version files of packs.
abstract class PackVersionParser {
  /// Parse the version of a pack from a file.
  static Future<String?> parsePackVersion(File versionFile) async {
    String? packVersion;

    // Read the file into multiple lines
    Stream<List<int>> inputStream = versionFile.openRead();
    var lines = utf8.decoder.bind(inputStream).transform(LineSplitter());
    // Extract the version from the lines
    try {
      await for (var line in lines) {
        packVersion = line;
        break;
      }
    } catch (e) {
      print("Error parsing ${versionFile.path}");
      print(e);
    }

    return packVersion;
  }
}
