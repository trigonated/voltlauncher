import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/repository/local/packversionparser.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';

/// An installed Pack.
class LocalPack {
  /// The name/id of the pack.
  final String name;

  /// The path to this pack.
  final String path;

  /// The installed version of the pack.
  final String? version;

  LocalPack({
    required this.name,
    required this.path,
    required this.version,
  });

  static Future<LocalPack?> fromPackDirectory(PackDirectory directory) async {
    return LocalPack(
      name: directory.name,
      path: directory.path,
      version: (directory.parent.versionFile(directory.name).existsSync())
          ? await PackVersionParser.parsePackVersion(directory.parent.versionFile(directory.name))
          : null,
    );
  }

  factory LocalPack.fromJson(Map<String, dynamic> json) {
    return LocalPack(
      name: json['name'],
      path: json['path'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'path': this.path,
      'version': this.version,
    };
  }

  Pack toPack() {
    return Pack(
      source: null,
      name: this.name,
      description: null,
      installedVersion: version,
      latestVersion: null,
      downloadUrl: null,
      checksum: null,
    );
  }
}
