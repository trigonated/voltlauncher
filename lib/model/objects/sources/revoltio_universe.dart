import 'package:voltlauncher/model/apis/revoltio/io_api.dart';
import 'package:voltlauncher/model/apis/revoltio/io_repo.dart';
import 'package:voltlauncher/model/objects/profiles/profilepreset.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';

/// The default built-in universe.
abstract class RevoltIOUniverse extends Universe {
  static const String revoltIOName = "Re-Volt I/O";
  static const String revoltIOWebsite = "https://re-volt.io/";
  static const String revoltIOIcon = "https://re-volt.io/user/themes/bolt/images/favicon.png";

  RevoltIOUniverse({
    required String name,
    required String? iconUrl,
    required String url,
    required String? website,
    required List<ContentSource> sources,
  }) : super(
          name: name,
          iconUrl: iconUrl,
          url: url,
          website: website,
          sources: sources,
        );

  /// Load the universe.
  static Future<Universe> load() async {
    Universe universe = Universe(
      name: revoltIOName,
      iconUrl: revoltIOIcon,
      url: RevoltIOUniverse.revoltIOWebsite,
      website: RevoltIOUniverse.revoltIOWebsite,
      sources: [],
    );

    // Load the repositories
    universe.sources.add(PackRepository.revoltIOMain(
      universe: universe,
      name: revoltIOName,
      iconUrl: revoltIOIcon,
      url: "https://distribute.re-volt.io/packages.json",
    ));
    List<IORepo> thirdPartyRepos = await IOApi.fetchThirdPartyRepositories(
      source: universe,
      url: "https://re-volt.gitlab.io/rvio/repos/repos.json",
    );
    universe.sources.addAll(thirdPartyRepos
        .map((e) => PackRepository.revoltIO(
              universe: universe,
              name: e.name,
              iconUrl: null,
              url: e.extraData.url,
            ))
        .toList());

    // Load the events sources
    universe.sources.add(EventsSource.revoltIO(
      universe: universe,
      name: revoltIOName,
      iconUrl: revoltIOIcon,
      url: "https://re-volt.io/events-data",
    ));

    // Load the news sources
    universe.sources.add(NewsSource.revoltIO(
      universe: universe,
      name: revoltIOName,
      iconUrl: revoltIOIcon,
      url: "https://re-volt.io/blog?return-as=json",
    ));

    // Load the presets sources
    PresetsSource presetsSource = PresetsSource.inline(
      universe: universe,
      name: revoltIOName,
      presets: [],
    );
    presetsSource.presets = [
      ProfilePreset(
        source: presetsSource,
        name: "Original game",
        description: "The original game including Dreamcast cars and tracks.",
        imageUrl: "default:classic",
        enabledSources: null,
        enabledPacks: [
          "game_files",
          "rvgl_assets",
          "rvgl_dcpack",
          "local"
        ],
        optionalContentLabel: "Include original soundtrack",
        optionalPacks: [
          "soundtrack",
        ],
      ),
      ProfilePreset(
        source: presetsSource,
        name: "Online-ready",
        description: "Everything needed to play online on the Re-Volt I/O community.",
        imageUrl: null,
        enabledSources: null,
        enabledPacks: [
          "game_files",
          "rvgl_assets",
          "rvgl_dcpack",
          "io_tracks",
          "io_tracks_bonus",
          "io_tracks_circuit",
          "io_cars",
          "io_cars_bonus",
          "io_skins",
          "io_skins_bonus",
          "io_lmstag",
          "io_loadlevel",
          "io_clockworks",
          "io_clockworks_modern",
          "local"
        ],
        optionalContentLabel: "Include community-made soundtrack",
        optionalPacks: [
          "io_music",
          "io_soundtrack",
        ],
      ),
    ];
    universe.sources.add(presetsSource);

    return universe;
  }
}
