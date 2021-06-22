import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/universe.dart';

/// A source of events.
class EventsSource extends ContentSource {
  /// The type of API.
  final EventsSourceApiType apiType;

  EventsSource({
    required Universe? universe,
    required String name,
    required String? iconUrl,
    required String url,
    required this.apiType,
  }) : super(type: ContentSourceType.events_source, universe: universe, name: name, iconUrl: iconUrl, url: url);

  factory EventsSource.volt({required Universe? universe, required String name, required String? iconUrl, required String url}) => EventsSource(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: EventsSourceApiType.volt,
      );

  factory EventsSource.revoltIO({required Universe? universe, required String name, required String? iconUrl, required String url}) => EventsSource(
        universe: universe,
        name: name,
        iconUrl: iconUrl,
        url: url,
        apiType: EventsSourceApiType.revoltIO,
      );

  factory EventsSource.fromJson(Map<String, dynamic> json, {required Universe? universe, required String name, required String? iconUrl, required String url}) {
    return EventsSource(
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

enum EventsSourceApiType {
  volt,
  revoltIO,
}

EventsSourceApiType _parseApiType(String? value) {
  switch (value?.toLowerCase()) {
    case "volt":
      return EventsSourceApiType.volt;
    case "revoltio":
      return EventsSourceApiType.revoltIO;
    default:
      return EventsSourceApiType.volt;
  }
}

String _apiTypeToString(EventsSourceApiType type) {
  switch (type) {
    case EventsSourceApiType.volt:
      return "volt";
    case EventsSourceApiType.revoltIO:
      return "revoltIO";
  }
}
