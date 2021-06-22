import 'dart:io';
import 'dart:convert';

/// Parser for track parameters files.
abstract class TrackParametersParser {
  /// Parse the track name of a parameters file.
  static Future<String?> parseTrackName(File parametersFile) async {
    String? trackName;

    // Read the file into multiple lines
    Stream<List<int>> inputStream = parametersFile.openRead();
    var lines = utf8.decoder.bind(inputStream).transform(LineSplitter());
    // Find and extract the track name from the lines
    try {
      RegExp getStringValueQuotesRegEx = new RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"');
      RegExp getStringValueApostropheRegEx = new RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'");
      await for (var line in lines) {
        if (line.toLowerCase().trim().startsWith("name")) {
          trackName = getStringValueQuotesRegEx.stringMatch(line)?.replaceAll('"', "");
          if (trackName == null) trackName = getStringValueApostropheRegEx.stringMatch(line)?.replaceAll("'", "");
          break;
        }
      }
    } catch (e) {
      print("Error parsing ${parametersFile.path}");
      print(e);
    }

    return trackName;
  }
}
