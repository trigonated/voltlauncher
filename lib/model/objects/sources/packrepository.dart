import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';

/// A source of packs (pack repository).
class PackRepository extends ContentSource {
  /// The type of API.
  final PackRepositoryApiType apiType;

  PackRepository({
    required Universe? universe,
    required String name,
    required String? iconUrl,
    required String url,
    required this.apiType,
  }) : super(type: ContentSourceType.repository, universe: universe, name: name, iconUrl: iconUrl, url: url);

  factory PackRepository.volt({required Universe? universe, required String name, required String? iconUrl, required String url}) => PackRepository(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: PackRepositoryApiType.volt,
      );

  factory PackRepository.revoltIO({required Universe? universe, required String name, required String? iconUrl, required String url}) => PackRepository(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: PackRepositoryApiType.revoltIO,
      );

  factory PackRepository.revoltIOMain({required Universe? universe, required String name, required String? iconUrl, required String url}) => PackRepository(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: PackRepositoryApiType.revoltIOMain,
      );

  factory PackRepository.fromJson(Map<String, dynamic> json, {required Universe? universe, required String name, required String? iconUrl, required String url}) {
    return PackRepository(
      universe: universe,
      name: name,
      iconUrl: iconUrl,
      url: url,
      apiType: _parseApiType(json['apiType']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = super.toJson();
    json['apiType'] = _apiTypeToString(this.apiType);
    return json;
  }
}

enum PackRepositoryApiType {
  volt,
  revoltIO,
  revoltIOMain,
}

PackRepositoryApiType _parseApiType(String? value) {
  switch (value?.toLowerCase()) {
    case "volt":
      return PackRepositoryApiType.volt;
    case "revoltio":
      return PackRepositoryApiType.revoltIO;
    case "revoltiomain":
      return PackRepositoryApiType.revoltIOMain;
    default:
      return PackRepositoryApiType.volt;
  }
}

String _apiTypeToString(PackRepositoryApiType type) {
  switch (type) {
    case PackRepositoryApiType.volt:
      return "volt";
    case PackRepositoryApiType.revoltIO:
      return "revoltIO";
    case PackRepositoryApiType.revoltIOMain:
      return "revoltIOMain";
  }
}