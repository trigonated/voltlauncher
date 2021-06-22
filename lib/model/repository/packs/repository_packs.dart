import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/file_extensions.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/apis/revoltio/io_api.dart';
import 'package:voltlauncher/model/apis/revoltio/io_pack.dart';
import 'package:voltlauncher/model/objects/local/local_pack.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';
import 'package:voltlauncher/model/repository/packs/installlocalpack_longtask.dart';
import 'package:voltlauncher/model/repository/packs/installpack_longtask.dart';
import 'package:voltlauncher/model/repository/packs/uninstallpack_longtask.dart';
import 'package:voltlauncher/model/repository/packs/updatepack_longtask.dart';
import 'package:voltlauncher/model/repository/repository.dart';

class RepositoryPacks {
  /// The parent repository.
  late Repository _repository;

  /// The cache.
  late _RepositoryPacksCache _cache;

  /// See [packsStream].
  late StreamController<bool> _packsStreamController;

  /// Stream which notifies it's listeners when a pack is changed
  /// (installed, updated, uninstalled, etc).
  ///
  /// It's value is irrelevant.
  Stream<bool> get packsStream => this._packsStreamController.stream;

  RepositoryPacks(Repository repository) {
    _repository = repository;
    _cache = _RepositoryPacksCache();
    _packsStreamController = StreamController<bool>.broadcast();
  }

  /// Fetch all packs.
  ///
  /// [installedOnly] can be used to fetch only the installed packs.
  Future<List<Pack>> fetchPacks({bool refresh = false, bool installedOnly = false}) async {
    // Load from cache
    List<Pack>? packs = (!refresh) ? await this._cache.fetchPacksFromCache(installedOnly: installedOnly) : null;

    // Check if there's no cached packs (or refresh is true)
    if (packs == null) {
      // Obtain the installed packs
      List<LocalPack> installedPacks = await repository.local.fetchPacks(refresh: refresh);
      if (installedOnly) {
        packs = installedPacks.map((e) => e.toPack()).toList();
      } else {
        packs = [];
        // Get the repositories
        List<PackRepository> repositories = await _repository.sources.fetchRepositories();
        // Load the packs from each repository
        for (PackRepository repository in repositories) {
          switch (repository.apiType) {
            case PackRepositoryApiType.volt:
              // TODO: Handle this case.
              break;
            case PackRepositoryApiType.revoltIO:
              List<IOPack> ioPacks = await IOApi.fetchThirdPartyRepositoryPacks(source: repository, url: repository.url);
              packs.addAll(ioPacks.map((e) {
                Pack pack = e.toPack();
                pack.installedVersion = (installedPacks.firstWhereOrNull((element) => element.name == pack.name))?.version;
                return pack;
              }).toList());
              break;
            case PackRepositoryApiType.revoltIOMain:
              List<IOPack> ioPacks = await IOApi.fetchMainRepositoryPacks(source: repository, url: repository.url);
              packs.addAll(ioPacks.map((e) {
                Pack pack = e.toPack();
                pack.installedVersion = (installedPacks.firstWhereOrNull((element) => element.name == pack.name))?.version;
                return pack;
              }).toList());
              break;
          }
        }
        // Add the packs that are installed but not on repositories
        for (LocalPack installedPack in installedPacks) {
          if (!packs.any((e) => e.name == installedPack.name)) {
            packs.add(installedPack.toPack());
          }
        }
        // Update the cache (only when [installedOnly] is false)
        this._cache.savePacksToCache(packs);
      }
      // Notify that a pack was changed
      notifyPacksChanged();
    }

    // Sort the packs by type
    packs.sort(Pack.compareByType);

    return packs;
  }

  /// Fetch a pack by it's [name].
  Future<Pack?> fetchPack({required String name, bool refresh = false, bool installedOnly = false}) async {
    return (await fetchPacks(refresh: refresh, installedOnly: installedOnly)).firstWhereOrNull((e) => (e.name == name));
  }

  /// Returns whether there are any updates for the installed packs.
  Future<bool> areUpdatesAvailable() async => (await fetchPacks(installedOnly: true)).any((e) => e.isUpdateAvailable);

  /// Install a pack. A new long task will be created.
  void installPack(Pack pack) => InstallPackLongTask(repository: _repository, pack: pack).start();

  /// Install a pack from a local archive. A new long task be created.
  void installLocalPack(File archiveFile) => InstallLocalPackLongTask(repository: _repository, archiveFile: archiveFile).start();

  /// Update an installed pack. A new long task will be created.
  void updatePack(Pack pack) => UpdatePackLongTask(repository: _repository, pack: pack).start();

  /// Install all installed packs (that have updates available). Multiple long tasks might be created.
  void updateAllPacks() async {
    (await fetchPacks(installedOnly: true)).where((e) => e.isUpdateAvailable).forEach((e) {
      updatePack(e);
    });
  }

  /// Uninstall a pack. A new long task will be created.
  ///
  /// Note: This actually deletes the pack from the current install. The user can
  /// alternatively disable it from the profile instead.
  void uninstallPack(Pack pack) => UninstallPackLongTask(repository: _repository, pack: pack).start();

  /// Call this when packs are changed (installed, updated, etc) to notify
  /// subscribers of [packsStream].
  void notifyPacksChanged() => _packsStreamController.add(true);

  /// Clears the cache.
  void clearCache() => this._cache.clear();
}

class _RepositoryPacksCache {
  List<Pack>? _packs;

  void clear() {
    LocalDirectories.appData.cache.packsFile.deleteIfExists();
    this._packs = null;
  }

  Future<List<Pack>?> fetchPacksFromCache({bool installedOnly = false}) async {
    if (this._packs != null) {
      // Data was already loaded
      if (installedOnly) {
        return this._packs!.where((e) => e.isInstalled).toList();
      } else {
        return this._packs;
      }
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.packsFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.packsFile.readAsString());
        List<Pack> loadedPacks = (await json.mapAsync((e) async => await Pack.fromJson(e))).toList();
        if (installedOnly) {
          return loadedPacks.where((e) => e.isInstalled).toList();
        } else {
          return loadedPacks;
        }
      } else {
        return null;
      }
    }
  }

  Future<bool> savePacksToCache(List<Pack> packs) async {
    this._packs = packs;

    List<dynamic> json = [];
    json.addAll(packs.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.packsFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }
}
