import 'package:intl/intl.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/model/objects/events/event_car.dart';
import 'package:voltlauncher/model/objects/events/event_lobby.dart';
import 'package:voltlauncher/model/objects/events/event_track.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';

/// An event from the Re-volt IO API.
/// This corresponds to the API's corresponding json object.
class IOEvent {
  final IOEventExtraData extraData;
  final String title;
  final DateTime date;
  final Map<String, String>? hosts;
  final String? category;
  final String? mode;
  final String? carClass;
  final String? otherclass;
  final String? tracklist;
  final String? content;

  IOEvent({
    required this.extraData,
    required this.title,
    required this.date,
    required this.hosts,
    required this.category,
    required this.mode,
    required this.carClass,
    required this.otherclass,
    required this.tracklist,
    required this.content,
  });

  factory IOEvent.fromJson({required EventsSource source, required String url, required Map<String, dynamic> json}) {
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy hh:mm");
    return IOEvent(
      extraData: IOEventExtraData(
        source: source,
        url: url,
      ),
      title: json['header']['title'],
      date: dateFormat.parse(json['header']['date']),
      hosts: json['header']['event']['hosts']?.map<String, String>((key, value) => MapEntry(key as String, value as String)),
      category: json['header']['event']['category'],
      mode: json['header']['event']['mode'],
      carClass: json['header']['event']['class'],
      otherclass: json['header']['event']['otherclass'],
      tracklist: json['header']['event']['tracklist'],
      content: json['content'],
    );
  }

  Event toEvent() {
    return Event(
      source: this.extraData.source,
      url: this.extraData.url,
      title: this.title,
      description: _parseDescription(),
      imageUrl: null,
      date: this.date,
      signupUrl: null,
      categories: (this.category != null) ? [this.category!] : null,
      modes: (this.mode != null) ? [this.mode!] : null,
      hosts: this.hosts?.keys.toList(),
      lobbies: this.hosts?.keys.map((key) => EventLobby(name: key, address: this.hosts![key])).toList(),
      allowedCars: _parseAllowedCars(),
      trackList: _parseTrackList(),
      requiredContent: null,
    );
  }

  String _parseDescription() {
    String result = "We will be racing ${this.carClass} cars at ${DateFormat("HH:mm").format(this.date)}";
    if ((this.content != null) && (this.content!.isNotEmpty)) {
      result += "\n\n" + this.content!;
    }
    return result;
  }

  List<EventCar> _parseAllowedCars() {
    List<EventCar> result = [];

    String name;
    bool stockOnly = false;
    bool withDC = true;
    String? url;
    if (this.carClass != null) {
      if ((this.carClass == "other") && (this.otherclass != null)) {
        switch (this.otherclass!.toLowerCase()) {
          case "stock rookie cars":
            name = "rookie";
            stockOnly = true;
            url = "https://revolt.fandom.com/wiki/List_of_Re-Volt_cars";
            break;
          case "stock amateur cars":
            name = "amateur";
            stockOnly = true;
            url = "https://revolt.fandom.com/wiki/List_of_Re-Volt_cars";
            break;
          case "stock advanced cars":
            name = "advanced";
            stockOnly = true;
            url = "https://revolt.fandom.com/wiki/List_of_Re-Volt_cars";
            break;
          case "stock semi-pro cars":
            name = "semi-pro";
            stockOnly = true;
            url = "https://revolt.fandom.com/wiki/List_of_Re-Volt_cars";
            break;
          case "stock pro cars":
            name = "pro";
            stockOnly = true;
            url = "https://revolt.fandom.com/wiki/List_of_Re-Volt_cars";
            break;
          default:
            name = this.otherclass!;
        }
      } else {
        name = this.carClass!;
        url = "https://re-volt.io/online/cars/${this.carClass!}";
      }
      result.add(EventCar.carClass(name, stockOnly: stockOnly, withDC: withDC, url: url));
    }

    final String carListHeader = "### Car Selection:";
    if ((this.content != null) && (this.content!.contains(carListHeader))) {
      List<String> carList = this.content!.substring(this.content!.indexOf(carListHeader) + carListHeader.length).split("\n* ");
      for (String car in carList) {
        if (car.isNotEmpty) {
          result.add(EventCar.car(car));
        }
      }
    }

    return result;
  }

  List<EventTrack> _parseTrackList() {
    if (this.tracklist == null) return [];

    List<String> tracks = this.tracklist!.split("\r\n");
    return tracks.map((track) {
      List<String> trackParts = track.split("\u2014").map((e) => e.trim()).toList();
      return EventTrack(
        name: trackParts[0].replaceAll("(R)", "").replaceAll("(M)", "").trim(),
        laps: int.parse(trackParts[1].substring(0, trackParts[1].indexOf(" "))),
        minutes: null,
        reverse: trackParts[0].contains("(R)"),
        mirrored: trackParts[0].contains("(M)"),
        pickups: null,
      );
    }).toList();
  }
}

class IOEventExtraData {
  final EventsSource source;
  final String url;

  IOEventExtraData({required this.source, required this.url});
}
