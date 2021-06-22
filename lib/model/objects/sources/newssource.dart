import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';

/// A source of news.
class NewsSource extends ContentSource {
  /// The type of API.
  final NewsSourceApiType apiType;

  NewsSource({
    required Universe? universe,
    required String name,
    required String? iconUrl,
    required String url,
    required this.apiType,
  }) : super(type: ContentSourceType.news_source, universe: universe, name: name, iconUrl: iconUrl, url: url);

  factory NewsSource.volt({required Universe? universe, required String name, required String? iconUrl, required String url}) => NewsSource(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: NewsSourceApiType.volt,
      );

  factory NewsSource.revoltIO({required Universe? universe, required String name, required String? iconUrl, required String url}) => NewsSource(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: NewsSourceApiType.revoltIO,
      );

  factory NewsSource.fromJson(Map<String, dynamic> json, {required Universe? universe, required String name, required String? iconUrl, required String url}) {
    return NewsSource(
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

enum NewsSourceApiType {
  volt,
  revoltIO,
}

NewsSourceApiType _parseApiType(String? value) {
  switch (value?.toLowerCase()) {
    case "volt":
      return NewsSourceApiType.volt;
    case "revoltio":
      return NewsSourceApiType.revoltIO;
    default:
      return NewsSourceApiType.volt;
  }
}

String _apiTypeToString(NewsSourceApiType type) {
  switch (type) {
    case NewsSourceApiType.volt:
      return "volt";
    case NewsSourceApiType.revoltIO:
      return "revoltIO";
  }
}
