import 'dart:async';
import 'dart:convert';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';
import 'package:voltlauncher/model/objects/sources/revoltio_universe.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';
import 'package:voltlauncher/model/repository/repository.dart';

class RepositorySources {
  /// The parent repository.
  // ignore: unused_field
  late Repository _repository;

  /// The cache.
  late _RepositorySourcesCache _cache;

  RepositorySources(Repository repository) {
    _repository = repository;
    _cache = _RepositorySourcesCache();
  }

  /// Fetch the sources.
  Future<List<ContentSource>> fetchSources({bool refresh = false, bool expanded = false, bool includePresetsSources = true}) async {
    // Load from cache
    if (!refresh) {
      List<ContentSource>? cachedSources = this._cache.fetchSourcesFromCache();
      if (cachedSources != null) {
        if (!expanded) {
          // Return only the root-level sources
          return cachedSources.where((e) => ((!(e is PresetsSource)) || (includePresetsSources))).toList();
        } else {
          // Return all sources, even those inside universes
          return cachedSources
              .expand((e) {
                if (e is Universe) {
                  return List<ContentSource>.of([e]).followedBy(e.sources);
                } else {
                  return [e];
                }
              })
              .where((e) => ((!(e is PresetsSource)) || (includePresetsSources)))
              .toList();
        }
      }
    }

    List<ContentSource> sources = [];
    // Load additional sources from the sources file
    sources.addAll(await _loadSources());
    // If there's no sources, load the default Revolt I/O universe
    if (sources.isEmpty) {
      sources.add(await RevoltIOUniverse.load());
      // Save the sources to avoid loading the default universe multiple times
      this._cache.saveSourcesToCache(sources);
      _saveSources();
    }

    this._cache.saveSourcesToCache(sources);
    if (!expanded) {
      // Return only the root-level sources
      return sources.where((e) => ((!(e is PresetsSource)) || (includePresetsSources))).toList();
    } else {
      // Return all sources, even those inside universes
      return sources
          .expand((e) {
            if (e is Universe) {
              return List<ContentSource>.of([e]).followedBy(e.sources);
            } else {
              return [e];
            }
          })
          .where((e) => ((!(e is PresetsSource)) || (includePresetsSources)))
          .toList();
    }
  }

  /// Add a new source.
  Future<void> addSource(ContentSource source) async {
    List<ContentSource> sources = this._cache.fetchSourcesFromCache() ?? await _loadSources();
    sources.add(source);
    this._cache.saveSourcesToCache(sources);
    await _saveSources();
  }

  /// Update a source.
  Future<void> updateSource(ContentSource source) async {
    await _saveSources();
  }

  /// Delete a source.
  Future<void> deleteSource(ContentSource source) async {
    List<ContentSource> sources = this._cache.fetchSourcesFromCache() ?? await _loadSources();
    if (source.universe != null) {
      // Source is inside an universe
      source.universe!.sources.remove(source);
    } else {
      // Source is at root level
      sources.remove(source);
    }
    this._cache.saveSourcesToCache(sources);
    await _saveSources();
  }

  /// Load the sources from the sources file.
  Future<List<ContentSource>> _loadSources() async {
    if (await LocalDirectories.appData.sourcesFile.exists()) {
      List<dynamic> json = jsonDecode(await LocalDirectories.appData.sourcesFile.readAsString());
      return json.map((e) => ContentSource.fromJson(e, universe: null)).toList();
    } else {
      return [];
    }
  }

  /// Save the sources to the sources file.
  Future<bool> _saveSources() async {
    List<ContentSource> sources = this._cache.fetchSourcesFromCache() ?? await _loadSources();
    List<dynamic> json = [];
    json.addAll(sources /*.where((e) => !(e is RevoltIOUniverse))*/ .map((e) => e.toJson()));
    await LocalDirectories.appData.sourcesFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }

  // Events

  Future<List<EventsSource>> fetchEventsSources({bool refresh = false}) async {
    List<ContentSource> sources = await fetchSources(refresh: refresh);

    List<EventsSource> eventsSources = [];
    for (ContentSource source in sources) {
      if (repository.currentProfile?.isSourceEnabled(source) == true) {
        if (source is Universe) {
          eventsSources.addAll(source.eventsSources);
        } else if (source is EventsSource) {
          eventsSources.add(source);
        }
      }
    }

    return eventsSources;
  }

  Future<EventsSource?> fetchEventsSource({required String url}) async => (await fetchEventsSources()).firstWhereOrNull((e) => (e.url == url));

  // News

  Future<List<NewsSource>> fetchNewsSources({bool refresh = false}) async {
    List<ContentSource> sources = await fetchSources(refresh: refresh);

    List<NewsSource> newsSources = [];
    for (ContentSource source in sources) {
      if (repository.currentProfile?.isSourceEnabled(source) == true) {
        if (source is Universe) {
          newsSources.addAll(source.newsSources);
        } else if (source is NewsSource) {
          newsSources.add(source);
        }
      }
    }

    return newsSources;
  }

  Future<NewsSource?> fetchNewsSource({required String url}) async => (await fetchNewsSources()).firstWhereOrNull((e) => (e.url == url));

  // Presets

  Future<List<PresetsSource>> fetchPresetsSources({bool refresh = false}) async {
    List<ContentSource> sources = await fetchSources(refresh: refresh);

    List<PresetsSource> presetsSources = [];
    for (ContentSource source in sources) {
      if (source is Universe) {
        presetsSources.addAll(source.presetsSources);
      } else if (source is PresetsSource) {
        presetsSources.add(source);
      }
    }

    return presetsSources;
  }

  Future<PresetsSource?> fetchPresetsSource({required String url}) async => (await fetchPresetsSources()).firstWhereOrNull((e) => (e.url == url));

  // Repositories

  Future<List<PackRepository>> fetchRepositories({bool enabledOnly = true, bool refresh = false}) async {
    List<ContentSource> sources = await fetchSources(refresh: refresh);

    List<PackRepository> repositories = [];
    for (ContentSource source in sources) {
      if ((!enabledOnly) || (repository.currentProfile?.isSourceEnabled(source) == true)) {
        if (source is Universe) {
          for (PackRepository repo in source.repositories) {
            if ((!enabledOnly) || (repository.currentProfile?.isSourceEnabled(repo) == true)) {
              repositories.add(repo);
            }
          }
        } else if (source is PackRepository) {
          repositories.add(source);
        }
      }
    }

    return repositories;
  }

  Future<PackRepository?> fetchRepository({bool enabledOnly = true, required String url}) async =>
      (await fetchRepositories(enabledOnly: enabledOnly)).firstWhereOrNull((e) => (e.url == url));

  /// Clears the cache.
  void clearCache() => this._cache.clear();
}

class _RepositorySourcesCache {
  List<ContentSource>? _sources;

  void clear() {
    this._sources = null;
  }

  List<ContentSource>? fetchSourcesFromCache() {
    return this._sources;
  }

  void saveSourcesToCache(List<ContentSource>? sources) {
    this._sources = sources;
  }
}
