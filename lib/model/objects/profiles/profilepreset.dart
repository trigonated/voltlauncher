import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';

/// A preset for creating a new profile.
class ProfilePreset {
  /// The source.
  final PresetsSource? source;

  /// The name of the preset.
  final String name;

  /// A description of the preset.
  final String? description;

  /// The url of the image of the preset.
  ///
  /// See [Assets.graphics.presets.fromDefaultUrl] for built-in urls.
  final String? imageUrl;

  /// The sources that will be enabled on the new profile.
  final List<String>? enabledSources;

  /// The packs that will be enabled on the new profile.
  final List<String> enabledPacks;

  /// The label for the optional content checkbox (e.g. "Include soundtrack").
  final String? optionalContentLabel;

  /// The packs that will be enabled if the optional content checkbox is checked.
  final List<String>? optionalPacks;

  /// Helper for the create profile page (DO NOT (DE)SERIALIZE THIS!!!)
  bool optionalContentChecked = true;

  /// Whether this is the "empty" profile.
  bool get isEmpty => ((this.enabledSources?.isEmpty == true) && (this.enabledPacks.isEmpty == true));

  /// Whether this preset has optional content.
  bool get hasOptionalContent => (this.optionalPacks?.isNotEmpty == true);

  ProfilePreset({
    required this.source,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.enabledSources,
    required this.enabledPacks,
    required this.optionalContentLabel,
    required this.optionalPacks,
  });

  factory ProfilePreset.empty() => ProfilePreset(
        source: null,
        name: "Empty",
        description: "Create an empty profile. Some content is required to start the game.",
        imageUrl: null,
        enabledSources: [],
        enabledPacks: [],
        optionalContentLabel: null,
        optionalPacks: null,
      );

  factory ProfilePreset.copyProfile({required AppProfile profile}) => ProfilePreset(
        source: PresetsSource.profile(profile: profile),
        name: "Clone \"${profile.name}\"",
        description: "Create a new profile based on the \"${profile.name}\" profile.",
        imageUrl: null,
        enabledSources: profile.enabledSources,
        enabledPacks: profile.enabledPacks,
        optionalContentLabel: null,
        optionalPacks: null,
      );

  static ProfilePreset inlineFromJson(Map<String, dynamic> json, {required PresetsSource? source}) {
    return ProfilePreset(
      source: source,
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      enabledSources: json['enabledSources']?.map<String>((e) => e as String).toList(),
      enabledPacks: json['enabledPacks']?.map<String>((e) => e as String).toList(),
      optionalContentLabel: json['optionalContentLabel'],
      optionalPacks: json['optionalPacks']?.map<String>((e) => e as String).toList(),
    );
  }

  static Future<ProfilePreset> fromJson(Map<String, dynamic> json) async {
    return ProfilePreset(
      source: (json['source'] != null) ? (await repository.sources.fetchPresetsSource(url: json['source'])) : null,
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      enabledSources: json['enabledSources']?.map<String>((e) => e as String).toList(),
      enabledPacks: json['enabledPacks']?.map<String>((e) => e as String).toList(),
      optionalContentLabel: json['optionalContentLabel'],
      optionalPacks: json['optionalPacks']?.map<String>((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': this.source?.url,
      'name': this.name,
      'description': this.description,
      'imageUrl': this.imageUrl,
      'enabledSources': this.enabledSources,
      'enabledPacks': this.enabledPacks,
      'optionalContentLabel': this.optionalContentLabel,
      'optionalPacks': this.optionalPacks,
    };
  }
}
