import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';

/// An user profile.
class AppProfile {
  /// The id of the profile.
  final String id;

  /// The display name of the profile.
  String name;

  /// The install associated with the profile.
  String install;

  /// The sources that are enabled.
  List<String> enabledSources;

  /// The packs that are enabled.
  List<String> enabledPacks;

  /// The selected launch parameters.
  AppProfileLaunchParameters launchParameters;

  /// The profile's icon file.
  File get iconFile => LocalDirectories.appData.profiles.profile(this.id).iconFile;

  AppProfile({
    required this.id,
    required this.name,
    required this.install,
    required this.enabledSources,
    required this.enabledPacks,
    required this.launchParameters,
  });

  factory AppProfile.defaultSettings({required String id}) => AppProfile(
        id: id,
        name: id,
        install: "default",
        enabledSources: [],
        enabledPacks: [],
        launchParameters: AppProfileLaunchParameters.empty(),
      );

  /// Special profile used when no profile is selected.
  static AppProfile none = AppProfile.defaultSettings(id: "");

  /// Change the name of the profile to [newName].
  Future<bool> changeName(String newName) async {
    // Do nothing if the new name is the same or already existing
    if (this.name == newName) return true;
    if (await repository.profiles.fetchProfile(name: newName) != null) {
      return false;
    }
    // Change the name
    this.name = newName;
    return await repository.profiles.saveProfile(this);
  }

  /// Change the profile's icon with [imageFile].
  Future<void> changeIcon(File imageFile) async {
    if (await imageFile.exists()) {
      Uint8List bytes = await imageFile.readAsBytes();
      await _setIcon(ByteData.view(bytes.buffer));
    }
  }

  /// Change the icon.
  Future<void> _setIcon(ByteData iconData) async {
    File file = LocalDirectories.appData.profiles.profile(this.id).iconFile;
    await file.create(recursive: true);
    await file.writeAsBytes(iconData.buffer.asUint8List(iconData.offsetInBytes, iconData.lengthInBytes));
  }

  /// Reset the profile icon to the default icon.
  Future<void> resetIcon() async {
    await _setIcon(await rootBundle.load(Assets.graphics.profile_default));
  }

  /// Change the install used by this profile.
  Future<bool> changeInstall(String newInstall) async {
    if (this.install == newInstall) return true;
    String oldValue = this.install;
    this.install = newInstall;
    // If no other profile is using the old install, delete it
    if (!(await repository.profiles.fetchProfiles()).any((e) => e.install == oldValue)) {
      await repository.local.deleteInstall(name: oldValue);
    }
    // Create the install if it doesn't exist
    await repository.local.createInstall(name: newInstall);
    // Save the profile
    return await repository.profiles.saveProfile(this);
  }

  /// Get whether a source is enabled for this profile.
  /// Use [recursive] to include also check the source's universe.
  bool isSourceEnabled(ContentSource source, {bool recursive = true}) {
    if ((recursive) && (source.universe != null)) {
      return ((this.enabledSources.contains(source.universe!.url)) && (this.enabledSources.contains(source.url)));
    } else {
      return (this.enabledSources.contains(source.url));
    }
  }

  /// Disable a source for this profile.
  Future<bool> disableSource(ContentSource source) async {
    if (this.enabledSources.contains(source.url)) {
      this.enabledSources.remove(source.url);
      repository.clearCache();
      // TODO: repository.packs.notifyPacksChanged();
      return await repository.profiles.saveProfile(this);
    } else {
      return true;
    }
  }

  /// Enable a source for this profile.
  Future<bool> enableSource(ContentSource source) async {
    if (!this.enabledSources.contains(source.url)) {
      this.enabledSources.add(source.url);
      repository.clearCache();
      // TODO: repository.packs.notifyPacksChanged();
      return await repository.profiles.saveProfile(this);
    } else {
      return true;
    }
  }

  /// Gets whether a pack is enabled for this profile.
  bool isPackEnabled(Pack pack) => (this.enabledPacks.contains(pack.name));

  /// Disable a pack for this profile.
  Future<bool> disablePack(Pack pack) async {
    if (this.enabledPacks.contains(pack.name)) {
      this.enabledPacks.remove(pack.name);
      repository.packs.clearCache();
      repository.packs.notifyPacksChanged();
      return await repository.profiles.saveProfile(this);
    } else {
      return true;
    }
  }

  /// Enable a pack for this profile.
  Future<bool> enablePack(Pack pack) async {
    if (!this.enabledPacks.contains(pack.name)) {
      this.enabledPacks.add(pack.name);
      repository.packs.clearCache();
      await repository.profiles.saveProfile(this);
      repository.packs.notifyPacksChanged();
      return true;
    } else {
      return true;
    }
  }

  /// Save the changed launched parameters, if any.
  Future<bool> saveLaunchParameters() async {
    return await repository.profiles.saveProfile(this);
  }

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    return AppProfile(
      id: json['id'],
      name: json['name'],
      install: json['install'],
      enabledSources: json['enabledSources']?.map<String>((e) => e.toString())?.toList() ?? [],
      enabledPacks: json['enabledPacks']?.map<String>((e) => e.toString())?.toList() ?? [],
      launchParameters: AppProfileLaunchParameters.fromJson(json['launchParameters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': this.id,
      'name': this.name,
      'install': this.install,
      'enabledSources': this.enabledSources,
      'enabledPacks': this.enabledPacks,
      'launchParameters': this.launchParameters,
    };
  }

  /// Transform a profile name into an id.
  static String idfyName(String name) => name.replaceAll(RegExp(r'[^\w]'), "").toLowerCase();
}

/// Game launch parameters for this profile.
class AppProfileLaunchParameters {
  /// A map of the app-configurable(shown in the launcher) parameters.
  late Map<String, String> _parameters;
  /// Aditional launch parameters.
  late String? additionalParameters;

  AppProfileLaunchParameters({
    required Map<String, String> parameters,
    required String? additionalParameters,
  }) {
    this._parameters = parameters;
    this.additionalParameters = additionalParameters;
  }

  factory AppProfileLaunchParameters.empty() {
    return AppProfileLaunchParameters(
      parameters: {},
      additionalParameters: null,
    );
  }

  /// Get the value of a boolean parameter.
  bool getFlagParameter(String name) {
    return this._parameters.containsKey(name);
  }

  /// Set the value of a boolean parameter.
  void setFlagParameter(String name, bool value) {
    if (value) {
      this._parameters[name] = "";
    } else {
      this._parameters.remove(name);
    }
  }

  /// Return a copy of the launch parameters, with extra parameters added.
  AppProfileLaunchParameters withExtraPlayParameters({
    String? basepath,
    String? prefpath,
    String? packlist,
    String? lobby,
  }) {
    Map<String, String> parameters = {};
    parameters.addAll(this._parameters);
    if (basepath != null) parameters['basepath'] = basepath;
    if (prefpath != null) parameters['prefpath'] = prefpath;
    if (packlist != null) parameters['packlist'] = packlist;
    if (lobby != null) parameters['lobby'] = lobby;
    return AppProfileLaunchParameters(
      parameters: parameters,
      additionalParameters: this.additionalParameters,
    );
  }

  factory AppProfileLaunchParameters.fromJson(Map<String, dynamic> json) {
    Map<String, String> parameters = json.map((key, value) => MapEntry(key, value.toString()));
    // Remove the "play" parameters
    parameters.remove("basepath");
    parameters.remove("prefpath");
    parameters.remove("packlist");
    parameters.remove("lobby");
    String? additionalParameters;
    if (parameters.containsKey("additionalParameters")) {
      additionalParameters = parameters["additionalParameters"];
      parameters.remove("additionalParameters");
    }
    return AppProfileLaunchParameters(
      parameters: parameters,
      additionalParameters: additionalParameters,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, String> parameters = {};
    parameters.addAll(this._parameters);
    if (this.additionalParameters != null) {
      parameters["additionalParameters"] = this.additionalParameters!;
    }
    // Remove the "play" parameters
    parameters.remove("basepath");
    parameters.remove("prefpath");
    parameters.remove("packlist");
    parameters.remove("lobby");
    return parameters;
  }

  /// Return a list of parameters to pass to the game executable.
  List<String> toArgumentList() {
    List<String> args = [];
    for (var parameter in this._parameters.entries) {
      args.add("-" + parameter.key);
      if (parameter.value.trim().isNotEmpty) {
        args.add(parameter.value);
      }
    }
    if (this.additionalParameters != null) args.addAll(this.additionalParameters!.split(" "));
    return args;
  }
}
