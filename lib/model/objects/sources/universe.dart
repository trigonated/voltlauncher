import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';
import 'package:voltlauncher/model/objects/sources/revoltio_universe.dart';

/// A special content source that contains multiple sources.
///
/// A good use for an universe is to contain multiple sources related to a community.
class Universe extends ContentSource {
  final String? website;
  final List<ContentSource> sources;
  List<PackRepository> get repositories => sources.whereType<PackRepository>().toList();
  List<EventsSource> get eventsSources => sources.whereType<EventsSource>().toList();
  List<NewsSource> get newsSources => sources.whereType<NewsSource>().toList();
  List<PresetsSource> get presetsSources => sources.whereType<PresetsSource>().toList();

  bool get isOfficialRevoltIOSource => (this.website == RevoltIOUniverse.revoltIOWebsite);

  Universe({
    required String name,
    required String? iconUrl,
    required String url,
    required this.website,
    required this.sources,
  }) : super(type: ContentSourceType.universe, universe: null, name: name, iconUrl: iconUrl, url: url);

  factory Universe.fromJson(Map<String, dynamic> json, {required String name, required String? iconUrl, required String url}) {
    Universe universe = Universe(
      name: name,
      iconUrl: iconUrl,
      url: url,
      website: json['website'],
      sources: [],
    );
    universe.sources.addAll(json['sources'].map<ContentSource>((e) => ContentSource.fromJson(e, universe: universe)).toList());
    return universe;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['website'] = this.website;
    json['sources'] = this.sources.map((e) => e.toJson()).toList();
    return json;
  }
}
