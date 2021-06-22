import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/file_extensions.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/model/objects/local/local_car.dart';
import 'package:voltlauncher/model/objects/local/local_pack.dart';
import 'package:voltlauncher/model/objects/local/local_track.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/repository/repository.dart';

class RepositoryLocal {
  /// The parent repository.
  late Repository _repository;

  /// The cache.
  late _RepositoryLocalCache _cache;

  RepositoryLocal(Repository repository) {
    _repository = repository;
    _cache = _RepositoryLocalCache();
  }

  /// Fetch the list of installs
  Future<List<String>> fetchInstalls() async {
    return (await LocalDirectories.appData.installs.listInstalls()).map((e) => e.name).toList();
  }

  /// Fetch the list of installs
  List<String> fetchInstallsSync() {
    return (LocalDirectories.appData.installs.listInstallsSync()).map((e) => e.name).toList();
  }

  /// Create a new install
  Future<bool> createInstall({required String name}) async {
    InstallDirectory installDirectory = LocalDirectories.appData.installs.install(name);
    await installDirectory.recipes.directory.create(recursive: true);
    await installDirectory.packs.directory.create(recursive: true);
    await installDirectory.save.create(recursive: true);
    return true;
  }

  /// Delete an install
  Future<bool> deleteInstall({required String name}) async {
    await LocalDirectories.appData.installs.install(name).directory.delete(recursive: true);
    return true;
  }

  /// Save a RVGL recipe of a [profile].
  Future<bool> saveRecipe({required AppProfile profile}) async {
    List<Pack> enabledPacks = (await _repository.packs.fetchPacks(installedOnly: true)).where((e) => profile.enabledPacks.contains(e.name)).toList();
    Map<String, dynamic> recipeJson = {
      'title': profile.id,
      'description': "'${profile.name}' profile on Volt Launcher. Auto-generated, don't edit.",
      'packages': enabledPacks.map((e) => e.name).toList(),
      'writable': false,
    };
    File recipeFile = LocalDirectories.appData.installs.install(profile.install).recipes.recipeFile(profile.id);
    await recipeFile.create(recursive: true);
    await recipeFile.writeAsString(JsonEncoder.withIndent('\t').convert(recipeJson));
    return true;
  }

  /// Save a packlist file of a [profile].
  Future<bool> savePacklist({required AppProfile profile}) async {
    List<String> enabledPacks = profile.enabledPacks;
    String content = "";
    for (var enabledPack in enabledPacks) {
      content += "\"$enabledPack\"";
      if (enabledPack == "local") {
        content += " *";
      }
      content += "\r\n";
    }
    File packlistFile = LocalDirectories.appData.installs.install(profile.install).packs.packlistFile(profile.id);
    await packlistFile.create(recursive: true);
    await packlistFile.writeAsString(content);
    return true;
  }

  /// Load the packs present on the current install.
  Future<List<LocalPack>> _loadPacksFromCurrentInstall() async {
    List<LocalPack> packs = [];
    // List all packs
    List<PackDirectory> packDirs = await LocalDirectories.appData.installs.currentInstall.packs.listPacks();
    for (PackDirectory packDir in packDirs) {
      // Load the pack
      LocalPack? pack = await LocalPack.fromPackDirectory(packDir);
      if (pack != null) {
        packs.add(pack);
      }
    }
    return packs;
  }

  /// Fetch the installed packs.
  Future<List<LocalPack>> fetchPacks({bool refresh = false}) async {
    // Load from cache
    List<LocalPack>? packs = (!refresh) ? await this._cache.fetchPacksFromCache() : null;
    // Check if there's no cached packs (or refresh is true)
    if (packs == null) {
      // Load the packs of the current install
      packs = await _loadPacksFromCurrentInstall();
      // Update the cache
      this._cache.savePacksToCache(packs);
    }

    return packs;
  }

  /// Fetch an installed pack by it's [name].
  Future<LocalPack?> fetchPack({required String name}) async => (await fetchPacks()).firstWhereOrNull((e) => (e.name == name));

  // Fetch an installed pack by it's [name].
  LocalPack? fetchPackSync({required String name}) => this._cache.fetchPacksFromCacheSync()?.firstWhereOrNull((e) => (e.name == name));

  /// Load the cars present on the current install.
  Future<List<LocalCar>> _loadCarsFromCurrentInstall() async {
    List<LocalCar> cars = [];
    // List all packs
    List<LocalPack> localPacks = await fetchPacks();
    for (LocalPack localPack in localPacks) {
      // Load the pack's cars
      List<CarDirectory> carDirs = await LocalDirectories.appData.installs.currentInstall.packs.pack(localPack.name).cars.listCars();
      for (CarDirectory carDir in carDirs) {
        // Load the car
        LocalCar? car = await LocalCar.fromCarDirectory(carDir);
        if (car != null) {
          cars.add(car);
        }
      }
    }
    return cars;
  }

  /// Fetch the cars.
  Future<List<LocalCar>> fetchCars({bool refresh = false}) async {
    // Load from cache
    List<LocalCar>? cars = (!refresh) ? await this._cache.fetchCarsFromCache() : null;
    // Check if there's no cached cars (or refresh is true)
    if (cars == null) {
      // Load the cars of the current install
      cars = await _loadCarsFromCurrentInstall();
      // Update the cache
      this._cache.saveCarsToCache(cars);
    }

    return cars;
  }

  /// Fetch a car, either by [id] or [name].
  Future<LocalCar?> fetchCar({String? id, String? name}) async => (await fetchCars()).firstWhereOrNull((e) => ((e.id == id) || (e.name == name)));

  /// Fetch a car, either by [id] or [name].
  LocalCar? fetchCarSync({String? id, String? name}) => this._cache.fetchCarsFromCacheSync()?.firstWhereOrNull((e) => ((e.id == id) || (e.name == name)));

  /// Load the tracks present on the current install.
  Future<List<LocalTrack>> _loadTracksFromCurrentInstall() async {
    List<LocalTrack> tracks = [];
    // List all packs
    List<LocalPack> localPacks = await fetchPacks();
    for (LocalPack localPack in localPacks) {
      // Load the pack's cars
      List<LevelDirectory> levelDirs = await LocalDirectories.appData.installs.currentInstall.packs.pack(localPack.name).levels.listLevels();
      for (LevelDirectory levelDir in levelDirs) {
        // Load the car
        LocalTrack? track = await LocalTrack.fromLevelDirectory(levelDir);
        if (track != null) {
          tracks.add(track);
        }
      }
    }
    return tracks;
  }

  /// Fetch the tracks.
  Future<List<LocalTrack>> fetchTracks({bool refresh = false}) async {
    // Load from cache
    List<LocalTrack>? tracks = (!refresh) ? await this._cache.fetchTracksFromCache() : null;
    // Check if there's no cached tracks (or refresh is true)
    if (tracks == null) {
      // Load the tracks of the current install
      tracks = await _loadTracksFromCurrentInstall();
      // Update the cache
      this._cache.saveTracksToCache(tracks);
    }

    return tracks;
  }

  /// Fetch a track, either by [id] or [name].
  Future<LocalTrack?> fetchTrack({String? id, String? name}) async => (await fetchTracks()).firstWhereOrNull((e) => ((e.id == id) ||
      (e.name.replaceAll("'", "").toLowerCase() == name?.toLowerCase()) ||
      (e.name.replaceAll("'", "").toLowerCase() == ((name ?? "") + " 1").toLowerCase())));

  /// Fetch a track, either by [id] or [name].
  LocalTrack? fetchTrackSync({String? id, String? name}) {
    return this._cache.fetchTracksFromCacheSync()?.firstWhereOrNull((e) => ((e.id == id) ||
        (e.name.replaceAll("'", "").toLowerCase() == name?.toLowerCase()) ||
        (e.name.replaceAll("'", "").toLowerCase() == ((name ?? "") + " 1").toLowerCase())));
  }

  /// Clears the cache.
  void clearCache() => this._cache.clear();
}

class _RepositoryLocalCache {
  List<LocalPack>? _packs;
  List<LocalCar>? _cars;
  List<LocalTrack>? _tracks;

  void clear() {
    LocalDirectories.appData.cache.localPacksFile.deleteIfExists();
    LocalDirectories.appData.cache.localCarsFile.deleteIfExists();
    LocalDirectories.appData.cache.localTracksFile.deleteIfExists();
    this._packs = null;
    this._cars = null;
    this._tracks = null;
  }

  Future<List<LocalPack>?> fetchPacksFromCache() async {
    if (this._packs != null) {
      // Data was already loaded
      return this._packs;
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.localPacksFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.localPacksFile.readAsString());
        return this._packs = json.map((e) => LocalPack.fromJson(e)).toList();
      } else {
        return null;
      }
    }
  }

  List<LocalPack>? fetchPacksFromCacheSync() {
    return this._packs;
  }

  Future<bool> savePacksToCache(List<LocalPack> packs) async {
    this._packs = packs;

    List<dynamic> json = [];
    json.addAll(packs.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.localPacksFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }

  Future<List<LocalCar>?> fetchCarsFromCache() async {
    if (this._cars != null) {
      // Data was already loaded
      return this._cars;
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.localCarsFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.localCarsFile.readAsString());
        return this._cars = json.map((e) => LocalCar.fromJson(e)).toList();
      } else {
        return null;
      }
    }
  }

  List<LocalCar>? fetchCarsFromCacheSync() {
    return this._cars;
  }

  Future<bool> saveCarsToCache(List<LocalCar> cars) async {
    this._cars = cars;

    List<dynamic> json = [];
    json.addAll(cars.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.localCarsFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }

  Future<List<LocalTrack>?> fetchTracksFromCache() async {
    if (this._tracks != null) {
      // Data was already loaded
      return this._tracks;
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.localTracksFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.localTracksFile.readAsString());
        return this._tracks = json.map((e) => LocalTrack.fromJson(e)).toList();
      } else {
        return null;
      }
    }
  }

  List<LocalTrack>? fetchTracksFromCacheSync() {
    return this._tracks;
  }

  Future<bool> saveTracksToCache(List<LocalTrack> tracks) async {
    this._tracks = tracks;

    List<dynamic> json = [];
    json.addAll(tracks.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.localTracksFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }
}
