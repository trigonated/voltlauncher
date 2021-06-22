import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';
import 'package:voltlauncher/model/objects/sources/revoltio_universe.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';
import 'package:voltlauncher/model/objects/sources/unknownsource.dart';

/// A source of content (events, packs, etc...)
abstract class ContentSource {
  /// The type of source.
  final ContentSourceType type;

  /// The universe containing this source.
  final Universe? universe;

  /// The name of the source.
  late String _name;

  /// The name of the source.
  String get name => _name;

  /// The url of this's source icon.
  final String? iconUrl;

  /// The url used to obtain the data.
  final String url;

  /// Get a unique display name.
  /// This turns multiple sources with the same name into semi-unique names
  /// (e.g. Re-volt IO -> Re-volt IO (Events)).
  String get uniqueName => _getUniqueName();

  /// Whether this source is one of the official Re-volt IO sources.
  bool get isOfficialRevoltIOSource => ((this.universe?.isOfficialRevoltIOSource == true) && (this.name == RevoltIOUniverse.revoltIOName));

  ContentSource({
    required this.type,
    required this.universe,
    required String name,
    required this.iconUrl,
    required this.url,
  }) {
    this._name = name;
  }

  factory ContentSource.fromJson(Map<String, dynamic> json, {required Universe? universe}) {
    ContentSourceType type = _parseType(json['type']);
    String name = json['name'];
    String? iconUrl = json['iconUrl'];
    String url = json['url'];
    switch (type) {
      case ContentSourceType.unknown:
        return UnknownSource.fromJson(json, universe: universe, name: name, iconUrl: iconUrl, url: url);
      case ContentSourceType.universe:
        return Universe.fromJson(json, name: name, iconUrl: iconUrl, url: url);
      case ContentSourceType.repository:
        return PackRepository.fromJson(json, universe: universe, name: name, iconUrl: iconUrl, url: url);
      case ContentSourceType.events_source:
        return EventsSource.fromJson(json, universe: universe, name: name, iconUrl: iconUrl, url: url);
      case ContentSourceType.news_source:
        return NewsSource.fromJson(json, universe: universe, name: name, iconUrl: iconUrl, url: url);
      case ContentSourceType.presets_source:
        return PresetsSource.fromJson(json, universe: universe, name: name, iconUrl: iconUrl, url: url);
    }
  }

  /// Rename this source.
  Future<void> rename(String newName) async {
    this._name = newName;
    await repository.sources.updateSource(this);
  }

  /// Delete this source.
  Future<void> delete() async {
    await repository.sources.deleteSource(this);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _typeToString(this.type),
      'name': this.name,
      'iconUrl': this.iconUrl,
      'url': this.url,
    };
  }

  /// Get a unique display name.
  /// This turns multiple sources with the same name into semi-unique names
  /// (e.g. Re-volt IO -> Re-volt IO (Events)).
  String _getUniqueName() {
    String name = this.name;
    if (this.universe?.name == this.name) {
      switch (this.type) {
        case ContentSourceType.unknown:
          name += " (Other)";
          break;
        case ContentSourceType.universe:
          name += " (Universe)";
          break;
        case ContentSourceType.repository:
          name += " (Packs)";
          break;
        case ContentSourceType.events_source:
          name += " (Events)";
          break;
        case ContentSourceType.news_source:
          name += " (News)";
          break;
        case ContentSourceType.presets_source:
          name += " (Presets)";
          break;
      }
    }
    return name;
  }
}

enum ContentSourceType {
  unknown,
  universe,
  repository,
  events_source,
  news_source,
  presets_source,
}

ContentSourceType _parseType(String? value) {
  switch (value?.toLowerCase()) {
    case "universe":
      return ContentSourceType.universe;
    case "repository":
      return ContentSourceType.repository;
    case "events_source":
      return ContentSourceType.events_source;
    case "news_source":
      return ContentSourceType.news_source;
    case "presets_source":
      return ContentSourceType.presets_source;
    default:
      return ContentSourceType.unknown;
  }
}

String _typeToString(ContentSourceType type) {
  switch (type) {
    case ContentSourceType.unknown:
      return "unknown";
    case ContentSourceType.universe:
      return "universe";
    case ContentSourceType.repository:
      return "repository";
    case ContentSourceType.events_source:
      return "events_source";
    case ContentSourceType.news_source:
      return "news_source";
    case ContentSourceType.presets_source:
      return "presets_source";
  }
}
