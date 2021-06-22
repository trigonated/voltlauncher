import 'dart:io';

import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';
import 'package:voltlauncher/model/repository/packs/installpack_longtask.dart';
import 'package:voltlauncher/model/repository/packs/uninstallpack_longtask.dart';
import 'package:voltlauncher/model/repository/packs/updatepack_longtask.dart';

/// A pack. Packs can contain tracks, cars, music, game files, etc...
class Pack {
  /// The source of this pack. `null` when the pack is local
  final PackRepository? source;

  /// The name/id of the pack.
  final String name;

  /// A description of the pack's contents.
  final String? description;

  /// What version of the pack is installed. `null` when the pack is not installed.
  String? installedVersion;

  /// The latest available version of the pack.
  final String? latestVersion;

  /// The url where the pack can be downloaded from.
  final String? downloadUrl;

  /// The checksum of the pack archive.
  final String? checksum;

  /// Whether this is a local pack (not installed from a repository).
  bool get isLocal => (this.name == "local");

  /// Whether the pack is installed.
  bool get isInstalled => ((this.installedVersion != null) || (this.latestVersion == null));

  /// Whether the pack is currently being installed.
  bool get isInstalling => repository.hasLongTask(InstallPackLongTask.generateId(this));

  /// The task related to the installation of this pack. `null` if the pack is not currently being installed.
  InstallPackLongTask? get installingTask => repository.fetchLongTask(InstallPackLongTask.generateId(this));

  /// Whether an update is available.
  bool get isUpdateAvailable => ((this.installedVersion != null) && (this.latestVersion != null) && (this.installedVersion != this.latestVersion));

  /// Whether this pack is being updated.
  bool get isUpdating => repository.hasLongTask(UpdatePackLongTask.generateId(this));

  /// The task related to the updating of this pack. `null` if the pack is not currently being updated.
  UpdatePackLongTask? get updatingTask => repository.fetchLongTask(UpdatePackLongTask.generateId(this));

  /// Whether this pack is currently being uninstalled.
  bool get isUninstalling => repository.hasLongTask(UninstallPackLongTask.generateId(this));

  /// The task related to the uninstallation of this pack. `null` if the pack is not currently being uninstalled.
  UninstallPackLongTask? get uninstallingTask => repository.fetchLongTask(UninstallPackLongTask.generateId(this));

  /// Whether this pack is enabled.
  bool get isEnabled => repository.currentProfile?.isPackEnabled(this) ?? false;

  /// The local directory of this pack.
  Directory get location => LocalDirectories.appData.installs.currentInstall.packs.pack(this.name).directory;

  Pack({
    required this.source,
    required this.name,
    required this.description,
    required this.installedVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.checksum,
  });

  static Future<Pack> fromJson(Map<String, dynamic> json) async {
    return Pack(
      source: (json['source'] != null) ? (await repository.sources.fetchRepository(url: json['source'])) : null,
      name: json['name'],
      description: json['description'],
      installedVersion: json['installedVersion'],
      latestVersion: json['latestVersion'],
      downloadUrl: json['downloadUrl'],
      checksum: json['checksum'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': this.source?.url,
      'name': this.name,
      'description': this.description,
      'installedVersion': this.installedVersion,
      'latestVersion': this.latestVersion,
      'downloadUrl': this.downloadUrl,
      'checksum': this.checksum,
    };
  }

  static final int Function(Pack a, Pack b) compareByType = (a, b) {
    // Sort by update available
    if ((a.isUpdateAvailable) && (!b.isUpdateAvailable)) {
      return -1;
    } else if ((!a.isUpdateAvailable) && (b.isUpdateAvailable)) {
      return 1;
    }
    // Sort by installed
    if ((a.isInstalled) && (!b.isInstalled)) {
      return -1;
    } else if ((!a.isInstalled) && (b.isInstalled)) {
      return 1;
    }
    // Sort by name
    return a.name.compareTo(b.name);
  };
}
