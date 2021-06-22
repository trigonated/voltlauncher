import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/misc/longtask.dart';
import 'package:voltlauncher/model/objects/events/event_lobby.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/model/objects/settings.dart';
import 'package:voltlauncher/model/repository/events/repository_events.dart';
import 'package:voltlauncher/model/repository/local/repository_local.dart';
import 'package:voltlauncher/model/repository/news/repository_news.dart';
import 'package:voltlauncher/model/repository/packs/repository_packs.dart';
import 'package:voltlauncher/model/repository/profiles/repository_profiles.dart';
import 'package:voltlauncher/model/repository/sources/repository_sources.dart';

class Repository {
  /// The queue of long tasks.
  ///
  /// See [longTasksStream] and [longTasksProgressStream] for related streams.
  final Queue<LongTask> longTasks = Queue();
  double _longTasksMaxProgress = 0;

  /// The app's settings.
  late AppSettings appSettings;

  /// Whether the app settings have been loaded.
  ///
  /// This exists to avoid making appSettings nullable.
  bool _loadedAppSettings = false;

  /// See [currentProfile].
  AppProfile? _currentProfile;

  /// The current profile.
  AppProfile? get currentProfile => _currentProfile;
  set currentProfile(AppProfile? value) {
    if ((_currentProfile != null) || (value == null)) {
      clearCache();
    }
    _currentProfile = value;
    notifyCurrentProfileChanged(value);
  }

  late RepositorySources sources;
  late RepositoryProfiles profiles;
  late RepositoryEvents events;
  late RepositoryNews news;
  late RepositoryPacks packs;
  late RepositoryLocal local;

  /// See [longTasksStream]
  late StreamController<bool> _longTasksStreamController;

  /// Stream that notifies when the queue of long tasks is changed.
  Stream<bool> get longTasksStream => this._longTasksStreamController.stream;

  /// See [longTasksProgressStream]
  late StreamController<double> _longTasksProgressStreamController;

  /// Stream that notifies when the total progress of the long tasks queue changes.
  ///
  /// The value is `-1` when there's no tasks.
  Stream<double> get longTasksProgressStream => this._longTasksProgressStreamController.stream;

  /// See [currentProfileStream]
  late StreamController<AppProfile> _currentProfileStreamController;

  /// Stream that notifies when the current profile is changed to a different profile.
  /// Due to null-safety, when no profile is selected, [AppProfile.none] is returned.
  Stream<AppProfile> get currentProfileStream => this._currentProfileStreamController.stream;

  Repository() {
    // Initialize the sub-repositories
    sources = RepositorySources(this);
    profiles = RepositoryProfiles(this);
    events = RepositoryEvents(this);
    news = RepositoryNews(this);
    packs = RepositoryPacks(this);
    local = RepositoryLocal(this);

    // Initialize the stream controllers
    _longTasksStreamController = StreamController<bool>.broadcast();
    _longTasksProgressStreamController = StreamController<double>.broadcast();
    _currentProfileStreamController = StreamController<AppProfile>.broadcast();
  }

  /// Initialize the repository.
  Future<bool> initialize() async {
    await loadSettings();
    await sources.fetchSources();
    await profiles.fetchProfiles();
    this.currentProfile = (this.appSettings.defaultProfile != null) ? await profiles.fetchProfile(id: this.appSettings.defaultProfile) : null;
    await local.fetchPacks();
    await local.fetchCars();
    await local.fetchTracks();
    return true;
  }

  /// Notify that the queue of long tasks has been changed.
  void notifyLongTasksChanged() {
    // Update the long tasks queue stream
    _longTasksStreamController.add(true);

    // Update the long tasks queue max progress
    if (this.longTasks.isNotEmpty) {
      this._longTasksMaxProgress = max(this.longTasks.length.toDouble(), this._longTasksMaxProgress);
    } else {
      this._longTasksMaxProgress = 0;
    }
    notifyLongTasksProgressChanged();
  }

  /// Notify that the total progress of the long tasks queue has changed.
  void notifyLongTasksProgressChanged() {
    if (this._longTasksMaxProgress > 0) {
      double progress;
      // Advance 1 for each task that was completed
      progress = (this._longTasksMaxProgress - this.longTasks.length.toDouble());
      // Add the current progresses
      for (LongTask longTask in this.longTasks) {
        progress += longTask.progress;
      }
      // Calculate the final value
      progress = min(progress / this._longTasksMaxProgress, 1.0);
      _longTasksProgressStreamController.add((progress != 1.0) ? progress : -1);
    } else {
      // There are no tasks
      _longTasksProgressStreamController.add(-1);
    }
  }

  /// Notify that the current profile has changed.
  void notifyCurrentProfileChanged(AppProfile? value) => _currentProfileStreamController.add(value ?? AppProfile.none);

  /// Get a long task by it's [id], returning `null` if it doesn't exist.
  ///
  /// [LongTask] classes usually have a [generateId] static method to generate ids.
  T? fetchLongTask<T extends LongTask>(String id) {
    LongTask? foundTask = longTasks.firstWhereOrNull((e) => e.id == id);
    return (foundTask != null) ? foundTask as T : null;
  }

  /// Gets whether a long task with [id] exists.
  bool hasLongTask(String id) => longTasks.any((element) => element.id == id);

  /// Load the application settings.
  ///
  /// If [reloadIfLoaded] is false, settings are only loaded if they
  /// already weren't.
  Future<bool> loadSettings({bool reloadIfLoaded = true}) async {
    // ignore: unnecessary_null_comparison
    if ((this._loadedAppSettings) && (!reloadIfLoaded)) return true;

    if (await LocalDirectories.appData.settingsFile.exists()) {
      // Load the settings file
      Map<String, dynamic> json = jsonDecode(await LocalDirectories.appData.settingsFile.readAsString());
      this.appSettings = AppSettings.fromJson(json);
      this._loadedAppSettings = true;
    } else {
      // The settings file doesn't exist. Create a new one
      print("Warning: ${LocalDirectories.appData.settingsFile.path} is missing, creating a new one");
      List<AppProfile> profiles = await this.profiles.fetchProfiles();
      String? defaultProfile = (profiles.isNotEmpty) ? profiles.first.id : null;
      this.appSettings = AppSettings.defaultSettings(defaultProfile: defaultProfile);
      this._loadedAppSettings = true;
      await saveSettings();
    }
    return true;
  }

  /// Save the application settings to the app settings file.
  Future<bool> saveSettings() async {
    await LocalDirectories.appData.settingsFile.create(recursive: true);
    await LocalDirectories.appData.settingsFile.writeAsString(JsonEncoder.withIndent('\t').convert(this.appSettings.toJson()));
    return true;
  }

  /// Start the game. An optional [lobby] can be provided to automatically
  /// join a game lobby.
  Future<bool> startGame({EventLobby? lobby}) async {
    if (this.currentProfile == null) return false;

    // Find the path to the game executable
    String? executable = _getGameExecutablePath();
    if (executable == null) return false;

    // Create the list of program arguments based on the launch parameters (with some extra params)
    List<String> arguments = this
        .currentProfile!
        .launchParameters
        .withExtraPlayParameters(
          basepath: LocalDirectories.appData.installs.currentInstall.path,
          prefpath: LocalDirectories.appData.installs.currentInstall.save.path,
          packlist: this.currentProfile!.id,
          lobby: lobby?.address,
        )
        .toArgumentList();
    // Start the game executable. Exit codes different than 0 are considered errors/crashes.
    ProcessResult result = await Process.run(executable, arguments);
    return (result.exitCode == 0);
  }

  /// Get the pack that contains the game executable, depending on the platform.
  String? getGameExecutablePackId() {
    if (Platform.isWindows) {
      return "rvgl_win64";
    } else if (Platform.isLinux) {
      return "rvgl_linux";
    } else {
      return null;
    }
  }

  /// Get the path to the game executable.
  String? _getGameExecutablePath() {
    if (this.currentProfile == null) return null;

    if (Platform.isWindows) {
      return LocalDirectories.appData.installs.currentInstall.packs.pack("rvgl_win64").file("rvgl.exe").path;
    } else if (Platform.isLinux) {
      return LocalDirectories.appData.installs.currentInstall.packs.pack("rvgl_linux").file("rvgl").path;
    } else {
      return null;
    }
  }

  /// Clear the cache.
  void clearCache() {
    this.events.clearCache();
    this.local.clearCache();
    this.news.clearCache();
    this.packs.clearCache();
    this.profiles.clearCache();
    this.sources.clearCache();
  }
}
