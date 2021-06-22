import 'dart:io';
import 'package:path/path.dart' as path_lib;
import 'package:voltlauncher/main.dart';

/// The directory where the app's local data(profiles, cache, etc...) is stored. This changes depending on the OS.
Directory get _systemAppDataDirectory {
  if (Platform.isWindows) {
    return Directory(path_lib.join(Platform.environment['UserProfile'] ?? "", 'AppData', 'Local'));
  } else if (Platform.isMacOS) {
    return Directory(path_lib.join(Platform.environment['HOME'] ?? "", 'Library', 'Application Support'));
  } else if (Platform.isLinux) {
    return Directory(path_lib.join('home', Platform.environment['HOME']));
  } else {
    throw Exception("${Platform.operatingSystem} is not supported");
  }
}

/// Local directories used by the app.
abstract class LocalDirectories {
  /// Directory where local data is stored.
  static ApplicationAppDataDirectory appData = ApplicationAppDataDirectory();
}

class ApplicationAppDataDirectory extends BaseSubDirectory {
  /// Cache directory.
  CacheDirectory get cache => CacheDirectory(this);

  /// Volt Launcher profiles directory.
  ProfilesDirectory get profiles => ProfilesDirectory(this);

  /// Installs(packs, game settings, saves) directory.
  InstallsDirectory get installs => InstallsDirectory(this);

  /// App settings file.
  File get settingsFile => file("settings.json");

  /// List of sources file.
  File get sourcesFile => file("sources.json");

  ApplicationAppDataDirectory() : super(parentPath: _systemAppDataDirectory.path, name: 'VoltLauncher');
}

/// .../cache
class CacheDirectory extends SubDirectory<ApplicationAppDataDirectory> {
  DownloadsDirectory get downloads => DownloadsDirectory(this);
  File get localCarsFile => file("localCars.json");
  File get localTracksFile => file("localTracks.json");
  File get localPacksFile => file("localPacks.json");
  File get upcomingEventsFile => file("upcomingEvents.json");
  File get newsFile => file("news.json");
  File get presetsFile => file("presets.json");
  File get packsFile => file("packs.json");

  CacheDirectory(ApplicationAppDataDirectory parent) : super(parent: parent, name: 'cache');
}

/// .../cache/downloads/<profile>
class DownloadsDirectory extends SubDirectory<CacheDirectory> {
  DownloadsDirectory(CacheDirectory parent) : super(parent: parent, name: 'downloads');
}

/// .../profiles
class ProfilesDirectory extends SubDirectory<ApplicationAppDataDirectory> {
  /// "default" profile directory.
  ProfileDirectory get defaultProfile => ProfileDirectory(this, "default");

  /// "[name]" profile directory.
  ProfileDirectory profile(String name) => ProfileDirectory(this, name);

  /// Get the list of profile directories.
  Future<List<ProfileDirectory>> listProfiles() async => (await listSubDirectories()).map((e) => ProfileDirectory(this, e.name)).toList();

  ProfilesDirectory(ApplicationAppDataDirectory parent) : super(parent: parent, name: 'profiles');
}

/// .../profiles/<profile>
class ProfileDirectory extends SubDirectory<ProfilesDirectory> {
  File get profileFile => file("profile.json");
  File get iconFile => file("icon.png");

  ProfileDirectory(ProfilesDirectory parent, String name) : super(parent: parent, name: name);
}

/// .../installs
class InstallsDirectory extends SubDirectory<ApplicationAppDataDirectory> {
  /// "default" install directory.
  InstallDirectory get defaultInstall => install("default");

  /// The install of the current profile. If no profile is selected, the "default" profile is returned.
  InstallDirectory get currentInstall => install(repository.currentProfile?.install);

  /// "[name]" install directory. If [name] is `null`, the "default" install is returned.
  InstallDirectory install(String? name) => (name != null) ? InstallDirectory(this, name) : defaultInstall;

  /// Get the list of install directories.
  Future<List<InstallDirectory>> listInstalls() async => (await listSubDirectories()).map((e) => InstallDirectory(this, e.name)).toList();

  /// Get the list of install directories.
  List<InstallDirectory> listInstallsSync() => (listSubDirectoriesSync()).map((e) => InstallDirectory(this, e.name)).toList();

  InstallsDirectory(ApplicationAppDataDirectory parent) : super(parent: parent, name: 'installs');
}

/// .../installs/<install>
class InstallDirectory extends SubDirectory<InstallsDirectory> {
  RecipesDirectory get recipes => RecipesDirectory(this);
  PacksDirectory get packs => PacksDirectory(this);
  Directory get save => Directory(path_lib.join(directory.path, 'save'));

  InstallDirectory(InstallsDirectory parent, String name) : super(parent: parent, name: name);
}

/// .../installs/<install>/recipes
class RecipesDirectory extends SubDirectory<InstallDirectory> {
  File defaultRecipeFile() => recipeFile("default");
  File recipeFile(String recipe) => file("$recipe.json");
  Future<List<File>> listRecipeFiles() async => (await listFiles()).where((e) => path_lib.extension(e.path) == ".json").toList();

  RecipesDirectory(InstallDirectory parent) : super(parent: parent, name: 'recipes');
}

/// .../installs/<install>/packs
class PacksDirectory extends SubDirectory<InstallDirectory> {
  /// "rvgl_assets" pack directory.
  RvglAssetsPackDirectory get rvglAssets => RvglAssetsPackDirectory(this);

  /// "[name]" pack directory.
  PackDirectory pack(String name) => PackDirectory(this, name);

  /// The version file for a pack.
  File versionFile(String packName) => file("$packName.ver");

  /// The packlist file for a profile.
  File packlistFile(String profileId) => file("$profileId.txt");

  /// Get the list of pack directories.
  Future<List<PackDirectory>> listPacks() async => (await listSubDirectories()).map((e) => PackDirectory(this, e.name)).toList();

  PacksDirectory(InstallDirectory parent) : super(parent: parent, name: 'packs');
}

/// .../installs/<install>/packs/<pack>
class PackDirectory extends SubDirectory<PacksDirectory> {
  CarsDirectory get cars => CarsDirectory(this);
  LevelsDirectory get levels => LevelsDirectory(this);
  GfxDirectory get gfx => GfxDirectory(this);

  PackDirectory(PacksDirectory parent, String name) : super(parent: parent, name: name);
}

/// .../installs/<install>/packs/rvgl_assets
class RvglAssetsPackDirectory extends PackDirectory {
  /// The car box for the stock car [name].
  StockCarCarBoxInfo stockCarCarbox(String name) {
    SubDirectory stockCarsDirectory = this.cars.car("misc");
    switch (name) {
      case "adeon":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 0, col: 1);
      case "amw":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 2, col: 2);
      case "beatall":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 1, col: 2);
      case "candy":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 0, col: 0);
      case "cougar":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 1, col: 2);
      case "dino":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 2, col: 2);
      case "flag":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 1, col: 1);
      case "fone":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 0, col: 2);
      case "gencar":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 0, col: 1);
      case "mite":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 0, col: 1);
      case "moss":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 1, col: 0);
      case "mouse":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 0, col: 1);
      case "mud":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 1, col: 1);
      case "panga":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 5, row: 1, col: 2);
      case "phat":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 0, col: 2);
      case "r5":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 2, col: 0);
      case "rc":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 0, col: 0);
      case "rotor":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 1, col: 1);
      case "sgt":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 2, col: 2);
      case "sugo":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 0, col: 2);
      case "tc1":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 1, col: 0);
      case "tc2":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 1, col: 2);
      case "tc3":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 0, col: 0);
      case "tc4":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 0, col: 2);
      case "tc5":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 2, row: 2, col: 1);
      case "tc6":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 2, col: 1);
      case "toyeca":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 3, row: 2, col: 1);
      case "volken":
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 1, row: 2, col: 0);
      default:
        return StockCarCarBoxInfo(directory: stockCarsDirectory, carBox: 5, row: 2, col: 0);
    }
  }

  RvglAssetsPackDirectory(PacksDirectory parent) : super(parent, "rvgl_assets");
}

class StockCarCarBoxInfo {
  final SubDirectory directory;
  final int carBox;
  final int row;
  final int col;
  File get file => directory.file("carbox${this.carBox}.bmp");

  StockCarCarBoxInfo({
    required this.directory,
    required this.carBox,
    required this.row,
    required this.col,
  });
}

/// .../installs/<install>/packs/<pack>/cars
class CarsDirectory extends SubDirectory<PackDirectory> {
  CarDirectory car(String name) => CarDirectory(this, name);
  Future<List<CarDirectory>> listCars() async => (await listSubDirectories()).map((e) => CarDirectory(this, e.name)).toList();

  CarsDirectory(PackDirectory parent) : super(parent: parent, name: 'cars');
}

/// .../installs/<install>/packs/<pack>/cars/<car>
class CarDirectory extends SubDirectory<CarsDirectory> {
  File get parametersFile => file("parameters.txt");
  File get carboxFile => file("carbox.bmp");

  CarDirectory(CarsDirectory parent, String name) : super(parent: parent, name: name);
}

/// .../installs/<install>/packs/<pack>/levels
class LevelsDirectory extends SubDirectory<PackDirectory> {
  LevelDirectory level(String name) => LevelDirectory(this, name);
  Future<List<LevelDirectory>> listLevels() async => (await listSubDirectories()).map((e) => LevelDirectory(this, e.name)).toList();

  LevelsDirectory(PackDirectory parent) : super(parent: parent, name: 'levels');
}

/// .../installs/<install>/packs/<pack>/levels/<level>
class LevelDirectory extends SubDirectory<LevelsDirectory> {
  File get parametersFile => file("${this.name}.inf");
  // File get altParametersFile => this.parent.parent.parent.pack("rvgl_assets").levels.level(this.name).parametersFile;
  // File get imageFile => this.parent.parent.gfx.levelImageFile(this.name);

  LevelDirectory(LevelsDirectory parent, String name) : super(parent: parent, name: name);
}

/// .../installs/<install>/packs/<pack>/gfx
class GfxDirectory extends SubDirectory<PackDirectory> {
  File levelImageFile(String levelName) => file("$levelName.bmp");

  GfxDirectory(PackDirectory parent) : super(parent: parent, name: 'gfx');
}

class SubDirectory<T extends BaseSubDirectory> extends BaseSubDirectory {
  final T parent;

  SubDirectory({required this.parent, name}) : super(parentPath: parent.path, name: name);
}

class BaseSubDirectory {
  final String parentPath;
  final String name;

  String get path => path_lib.join(this.parentPath, this.name);

  Directory get directory => Directory(path);

  File file(String filename) => File(path_lib.join(this.path, filename));

  Future<List<BaseSubDirectory>> listSubDirectories() async {
    if (await Directory(this.path).exists()) {
      return await Directory(this.path)
          .list()
          .where((e) => e is Directory)
          .asyncMap((e) => BaseSubDirectory(parentPath: this.path, name: path_lib.basename(e.path)))
          .toList();
    } else {
      return [];
    }
  }

  List<BaseSubDirectory> listSubDirectoriesSync() {
    if (Directory(this.path).existsSync()) {
      return Directory(this.path)
          .listSync()
          .where((e) => e is Directory)
          .map((e) => BaseSubDirectory(parentPath: this.path, name: path_lib.basename(e.path)))
          .toList();
    } else {
      return [];
    }
  }

  Future<List<File>> listFiles() async {
    if (await Directory(this.path).exists()) {
      return await Directory(this.path).list().where((e) => e is File).map((e) => e as File).toList();
    } else {
      return [];
    }
  }

  List<File> listFilesSync() {
    if (Directory(this.path).existsSync()) {
      return Directory(this.path).listSync().where((e) => e is File).map((e) => e as File).toList();
    } else {
      return [];
    }
  }

  BaseSubDirectory({required this.parentPath, required this.name});
}
