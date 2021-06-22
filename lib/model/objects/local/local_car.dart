import 'dart:io';

import 'package:voltlauncher/model/repository/local/carparametersparser.dart';
import 'package:voltlauncher/misc/localdirectories.dart';

/// An installed car.
class LocalCar {
  /// The car's real name (e.g. gencar).
  final String id;

  /// The car's directory.
  final String path;

  /// The id of the pack containing this car.
  final String packId;

  /// The display name (e.g. Genghis Kar).
  final String name;

  /// The path for the car's box image file.
  final String? boxArtPath;

  /// Whether this is a stock car.
  bool get isStock => (this.packId == "game_files");

  /// The car's box image file.
  File? get boxArt => (this.boxArtPath != null) ? File(this.boxArtPath!) : null;

  LocalCar({
    required this.id,
    required this.path,
    required this.packId,
    required this.name,
    required this.boxArtPath,
  });

  static Future<LocalCar?> fromCarDirectory(CarDirectory directory) async {
    File parametersFile = directory.parametersFile;
    if (await parametersFile.exists()) {
      String id = directory.name;
      String path = directory.path;
      String packId = directory.parent.parent.name;
      String? name = await CarParametersParser.parseCarName(parametersFile);
      if (name != null) {
        return LocalCar(
          id: id,
          path: path,
          packId: packId,
          name: name,
          boxArtPath: (packId == "game_files") ? directory.carboxFile.path : null,
        );
      }
    }
    return null;
  }

  factory LocalCar.fromJson(Map<String, dynamic> json) {
    return LocalCar(
      id: json['id'],
      path: json['path'],
      packId: json['packId'],
      name: json['name'],
      boxArtPath: json['boxArtPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'path': this.path,
      'packId': this.packId,
      'name': this.name,
      'boxArtPath': this.boxArtPath,
    };
  }
}
