import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/events/event_car.dart';
import 'package:voltlauncher/model/objects/events/event_contentrequirement.dart';
import 'package:voltlauncher/model/objects/events/event_lobby.dart';
import 'package:voltlauncher/model/objects/events/event_track.dart';
import 'package:voltlauncher/model/objects/events/event_contentrequirementfailure.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';

/// An event.
class Event {
  /// The source.
  final EventsSource source;

  /// The url. This is the event's webpage.
  final String? url;

  /// The title of the event.
  final String title;

  /// The description.
  final String? description;

  /// The url for the event's image.
  final String? imageUrl;

  /// The date the event starts.
  final DateTime date;

  /// An url used to signup for the event.
  final String? signupUrl;

  /// Categories (tags) of the event.
  final List<String>? categories;

  /// The game modes played in the event (e.g. race).
  final List<String>? modes;

  /// The hosts of the event.
  final List<String>? hosts;

  /// Lobbies of the event
  final List<EventLobby>? lobbies;

  /// The list of allowed cars/classes.
  final List<EventCar>? allowedCars;

  /// The list of tracks.
  final List<EventTrack>? trackList;

  /// The content this event requires.
  final List<EventContentRequirement>? requiredContent;

  /// Tags related to the event.
  List<String> get tags => (categories ?? []).followedBy(modes ?? []).toList();

  /// Whether the event has a lobby which can be joined from the launcher (has an address).
  bool get hasJoinableLobby => (lobbies ?? []).any((element) => element.address != null);

  /// Whether all the required content is fulfilled.
  bool get isRequiredContentFulfilled => repository.events.checkEventContentRequirements(this).isEmpty;

  /// The missing/outdated required content.
  List<EventContentRequirementFailure> get unfulfilledRequiredContent => repository.events.checkEventContentRequirements(this);

  Event({
    required this.source,
    required this.url,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.signupUrl,
    required this.categories,
    required this.modes,
    required this.hosts,
    required this.lobbies,
    required this.allowedCars,
    required this.trackList,
    required this.requiredContent,
  });

  static Future<Event> fromJson(Map<String, dynamic> json) async {
    return Event(
      source: (await repository.sources.fetchEventsSource(url: json['source']))!,
      url: json['url'],
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      date: DateTime.parse(json['date']),
      signupUrl: json['signupUrl'],
      categories: json['categories']?.map<String>((e) => e as String).toList(),
      modes: json['modes']?.map<String>((e) => e as String).toList(),
      hosts: json['hosts']?.map<String>((e) => e as String).toList(),
      lobbies: json['lobbies']?.map<EventLobby>((e) => EventLobby.fromJson(e)).toList(),
      allowedCars: json['allowedCars']?.map<EventCar>((e) => EventCar.fromJson(e)).toList(),
      trackList: json['trackList']?.map<EventTrack>((e) => EventTrack.fromJson(e)).toList(),
      requiredContent: json['requiredContent']?.map<EventContentRequirement>((e) => EventContentRequirement.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': this.source.url,
      'url': this.url,
      'title': this.title,
      'description': this.description,
      'imageUrl': this.imageUrl,
      'date': this.date.toString(),
      'signupUrl': this.signupUrl,
      'categories': this.categories,
      'modes': this.modes,
      'hosts': this.hosts,
      'lobbies': this.lobbies?.map((e) => e.toJson()).toList(),
      'allowedCars': this.allowedCars?.map((e) => e.toJson()).toList(),
      'trackList': this.trackList?.map((e) => e.toJson()).toList(),
      'requiredContent': this.requiredContent?.map((e) => e.toJson()).toList(),
    };
  }
}
