import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/model/objects/profiles/profilepreset.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';

/// A source of presets.
class PresetsSource extends ContentSource {
  /// The list of presets.
  List<ProfilePreset>? presets;

  /// Get the profile id defined in a "clone x profile" preset.
  String? get sourceProfileId => (this.url.startsWith("profile:")) ? this.url.substring("profile:".length) : null;

  PresetsSource({
    required Universe? universe,
    required String name,
    required String? iconUrl,
    required String url,
    this.presets,
  }) : super(type: ContentSourceType.presets_source, universe: universe, name: name, iconUrl: iconUrl, url: url);

  factory PresetsSource.profile({required AppProfile profile}) => PresetsSource(
        universe: null,
        name: profile.name,
        iconUrl: null,
        url: "profile:${profile.id}",
      );

  factory PresetsSource.inline({required Universe? universe, required String name, required List<ProfilePreset> presets}) => PresetsSource(
        universe: universe,
        name: name,
        iconUrl: null,
        url: "",
        presets: presets,
      );

  factory PresetsSource.fromJson(Map<String, dynamic> json,
      {required Universe? universe, required String name, required String? iconUrl, required String url}) {
    PresetsSource source = PresetsSource(
      universe: universe,
      name: name,
      iconUrl: iconUrl,
      url: url,
      presets: null,
    );
    source.presets = json['presets']?.map<ProfilePreset>((e) => ProfilePreset.inlineFromJson(e, source: source)).toList();
    return source;
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    if (this.presets != null) {
      json['presets'] = this.presets!.map((e) => e.toJson()).toList();
    }
    return json;
  }
}
