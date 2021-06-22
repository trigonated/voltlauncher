import 'dart:io';

import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/repository/local/trackparametersparser.dart';

/// An installed track.
class LocalTrack {
  /// The track's real name (e.g. muse2)
  final String id;

  /// The path to the track.
  final String path;

  /// The id of the pack containing this track.
  final String packId;

  /// The display name of the track (e.g. Museum 2).
  final String name;

  /// The path to the image of the track.
  final String? imagePath;

  /// Whether this is a stock track.
  bool get isStock => (this.packId == "game_files");

  /// The file of the image of the track.
  File? get image => (this.imagePath != null) ? File(this.imagePath!) : null;

  LocalTrack({
    required this.id,
    required this.path,
    required this.packId,
    required this.name,
    required this.imagePath,
  });

  static Future<LocalTrack?> fromLevelDirectory(LevelDirectory directory) async {
    File parametersFile = directory.parametersFile;
    File altParametersFile = directory.parent.parent.parent.pack("rvgl_assets").levels.level(directory.name).parametersFile;
    if (await parametersFile.exists()) {
      String id = directory.name;
      String path = directory.path;
      String packId = directory.parent.parent.name;
      String? name = await TrackParametersParser.parseTrackName((altParametersFile.existsSync()) ? altParametersFile : parametersFile);
      String imagePath = directory.parent.parent.gfx.levelImageFile(directory.name).path;
      if (name != null) {
        return LocalTrack(
          id: id,
          path: path,
          packId: packId,
          name: name,
          imagePath: imagePath,
        );
      }
    }
    return null;
  }

  factory LocalTrack.fromJson(Map<String, dynamic> json) {
    return LocalTrack(
      id: json['id'],
      path: json['path'],
      packId: json['packId'],
      name: json['name'],
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'path': this.path,
      'packId': this.packId,
      'name': this.name,
      'imagePath': this.imagePath,
    };
  }
}
