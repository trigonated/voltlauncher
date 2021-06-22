import 'dart:io';
import 'dart:convert';

/// Parser for car parameters files.
abstract class CarParametersParser {
  /// Parse the car name of a parameters file.
  static Future<String?> parseCarName(File parametersFile) async {
    String? carName;

    // Read the file into multiple lines
    Stream<List<int>> inputStream = parametersFile.openRead();
    var lines = utf8.decoder.bind(inputStream).transform(LineSplitter());
    // Find and extract the car name from the lines
    try {
      RegExp getStringValueQuotesRegEx = new RegExp(r'"[^"\\]*(?:\\.[^"\\]*)*"');
      RegExp getStringValueApostropheRegEx = new RegExp(r"'[^'\\]*(?:\\.[^'\\]*)*'");
      await for (var line in lines) {
        if (line.toLowerCase().trim().startsWith("name")) {
          carName = getStringValueQuotesRegEx.stringMatch(line)?.replaceAll('"', "");
          if (carName == null) carName = getStringValueApostropheRegEx.stringMatch(line)?.replaceAll("'", "");
          break;
        }
      }
    } catch (e) {
      print("Error parsing ${parametersFile.path}");
      print(e);
    }

    return carName;
  }
}
