import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';

/// A source of an unknown type.
class UnknownSource extends ContentSource {
  /// The name of the type of source.
  final String? unknownType;

  /// The fields loaded from the json.
  final Map<String, dynamic> fields;

  UnknownSource({
    required Universe? universe,
    required String name,
    required String? iconUrl,
    required String url,
    required this.unknownType,
    required this.fields,
  }) : super(type: ContentSourceType.events_source, universe: universe, name: name, iconUrl: iconUrl, url: url);

  factory UnknownSource.fromJson(Map<String, dynamic> json,
      {required Universe? universe, required String name, required String? iconUrl, required String url}) {
    return UnknownSource(
      universe: universe,
      name: name,
      iconUrl: iconUrl,
      url: url,
      unknownType: json['type'],
      fields: json,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return fields;
  }
}
