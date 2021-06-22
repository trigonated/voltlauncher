import 'dart:async';
import 'dart:convert';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/file_extensions.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/model/objects/profiles/profilepreset.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';
import 'package:voltlauncher/model/repository/repository.dart';

class RepositoryProfiles {
  /// The parent repository.
  late Repository _repository;

  /// The cache.
  late _RepositoryProfilesCache _cache;

  RepositoryProfiles(Repository repository) {
    _repository = repository;
    _cache = _RepositoryProfilesCache();
  }

  /// Fetch the profiles.
  Future<List<AppProfile>> fetchProfiles({bool refresh = false}) async {
    // Load from cache
    List<AppProfile>? profiles = (!refresh) ? this._cache.fetchProfilesFromCache() : null;

    // Check if there's no cached news (or refresh is true)
    if (profiles == null) {
      profiles = [];
      // List all profiles
      List<ProfileDirectory> profileDirs = await LocalDirectories.appData.profiles.listProfiles();
      for (ProfileDirectory profileDir in profileDirs) {
        // Load the profile
        AppProfile profile;
        if (await profileDir.profileFile.exists()) {
          Map<String, dynamic> json = jsonDecode(await profileDir.profileFile.readAsString());
          profile = AppProfile.fromJson(json);
        } else {
          print("Warning: ${profileDir.profileFile.path} is missing, creating a new one");
          profile = AppProfile.defaultSettings(id: profileDir.name);
          saveProfile(profile);
        }
        profiles.add(profile);
      }
      // Update the cache
      this._cache.saveProfilesToCache(profiles);
    }

    return profiles;
  }

  /// Fetch a profile, either by [id] or by [name].
  Future<AppProfile?> fetchProfile({String? id, String? name}) async {
    if ((id == null) && (name == null)) throw Exception("Must provide an id or a name");
    if ((id != null) && (name != null)) throw Exception("Must provide either an id **OR** a name");
    if (id != null) {
      return (await fetchProfiles()).firstWhereOrNull((e) => (e.id == id));
    } else {
      return (await fetchProfiles()).firstWhereOrNull((e) => (e.name == name));
    }
  }

  /// Save a profile (creating it if it doesn't exist).
  Future<bool> saveProfile(AppProfile profile) async {
    // Save the profile
    await LocalDirectories.appData.profiles.profile(profile.id).profileFile.create(recursive: true);
    await LocalDirectories.appData.profiles.profile(profile.id).profileFile.writeAsString(JsonEncoder.withIndent('\t').convert(profile.toJson()));
    // Save the rvgl recipe
    await _repository.local.saveRecipe(profile: profile);
    // Save the packlist file
    await _repository.local.savePacklist(profile: profile);

    return true;
  }

  /// Create a new profile from a specified [preset], named [name] and using the install [install].
  ///
  /// If [setAsCurrent] is set to `true`, the new profile is set as the current profile.
  Future<bool> createProfile({required ProfilePreset preset, required String name, required String install, required bool setAsCurrent}) async {
    // Create the profile
    AppProfile? profileToClone = (preset.source?.sourceProfileId != null) ? await fetchProfile(id: preset.source!.sourceProfileId!) : null;
    AppProfile newProfile = AppProfile(
      id: AppProfile.idfyName(name),
      name: name,
      install: install,
      enabledSources: preset.enabledSources ?? (await repository.sources.fetchSources(expanded: true)).map((e) => e.url).where((e) => e.isNotEmpty).toList(),
      enabledPacks: preset.enabledPacks
          .followedBy((preset.optionalContentChecked) ? preset.optionalPacks ?? [] : [])
          .followedBy((repository.getGameExecutablePackId() != null) ? [repository.getGameExecutablePackId()!] : [])
          .toList(),
      launchParameters: profileToClone?.launchParameters ?? AppProfileLaunchParameters.empty(),
    );
    await saveProfile(newProfile);
    await newProfile.resetIcon();

    // Create the install (if non-existing)
    if (!(await repository.local.fetchInstalls()).contains(install)) {
      await repository.local.createInstall(name: install);
    }

    // Clear the profiles cache
    this._cache.saveProfilesToCache(null);

    // Set as the current profile
    if (setAsCurrent) {
      repository.currentProfile = newProfile;
      repository.appSettings.defaultProfile = newProfile.id;

      // Start installing the enabled packs (if not installed)
      for (var enabledPack in newProfile.enabledPacks) {
        Pack? pack = await repository.packs.fetchPack(name: enabledPack);
        if (pack != null) {
          repository.packs.installPack(pack);
        }
      }
    }

    return true;
  }

  Future<bool> deleteProfile(AppProfile profile) async {
    // Delete the profile folder
    await LocalDirectories.appData.profiles.profile(profile.id).directory.delete(recursive: true);

    // Clear the profiles cache
    this._cache.saveProfilesToCache(null);

    // If the default profile setting is the deleted profile, pick another.
    if (repository.appSettings.defaultProfile == profile.id) {
      List<AppProfile> profiles = await fetchProfiles(refresh: true);
      repository.appSettings.defaultProfile = profiles.firstOrNull?.id;
    }

    // If the current profile is the deleted profile, reset it back to the default.
    if (repository.currentProfile == profile) {
      repository.currentProfile = (repository.appSettings.defaultProfile != null) ? await fetchProfile(id: repository.appSettings.defaultProfile) : null;
    }

    return true;
  }

  /// Generate the built-in (Empty profile, Clone x profile) presets.
  Future<List<ProfilePreset>> _generateBuiltInPresets() async {
    List<ProfilePreset> presets = [];

    // Add the "Empty" preset
    presets.add(ProfilePreset.empty());

    // Add the "Clone profile x" presets
    List<AppProfile> profiles = await fetchProfiles();
    presets.addAll(profiles.map((e) => ProfilePreset.copyProfile(profile: e)).toList());

    return presets;
  }

  /// Fetch the presets.
  Future<List<ProfilePreset>> fetchPresets({bool refresh = false}) async {
    // Load from cache
    List<ProfilePreset>? presets = (!refresh) ? await this._cache.fetchPresetsFromCache() : null;

    // Check if there's no cached presets (or refresh is true)
    if (presets == null) {
      presets = [];
      // Get the events sources
      List<PresetsSource> sources = await _repository.sources.fetchPresetsSources();
      // Load the presets from each source
      for (PresetsSource source in sources) {
        // Add the inline presets defined in the source itself
        if (source.presets != null) {
          presets.addAll(source.presets!);
        }
        // TODO: Implement loading remote presets
      }
      // Update the cache
      this._cache.savePresetsToCache(presets);
    }

    // Add the built-in presets
    presets.addAll(await _generateBuiltInPresets());

    return presets;
  }

  /// Clears the cache.
  void clearCache() => this._cache.clear();
}

class _RepositoryProfilesCache {
  List<AppProfile>? _profiles;
  List<ProfilePreset>? _presets;

  void clear() {
    LocalDirectories.appData.cache.presetsFile.deleteIfExists();
    this._presets = null;
  }

  List<AppProfile>? fetchProfilesFromCache() {
    return this._profiles;
  }

  void saveProfilesToCache(List<AppProfile>? profiles) {
    this._profiles = profiles;
  }

  Future<List<ProfilePreset>?> fetchPresetsFromCache() async {
    if (this._presets != null) {
      // Data was already loaded
      return this._presets;
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.presetsFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.presetsFile.readAsString());
        return this._presets = (await json.mapAsync((e) async => await ProfilePreset.fromJson(e))).toList();
      } else {
        return null;
      }
    }
  }

  Future<bool> savePresetsToCache(List<ProfilePreset> presets) async {
    this._presets = presets;

    List<dynamic> json = [];
    json.addAll(presets.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.presetsFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }
}
