import 'package:intl/intl.dart';

/// Entry (car/class) from an event's car list.
class EventCar {
  /// The type of entry (car or class).
  final EventCarType type;

  /// Name of the car/class.
  final String name;

  /// Whether this class is only stock cars.
  ///
  /// EventCarType.carClass exclusive
  final bool stockOnly;

  /// Whether this class contains Dreamcast cars.
  ///
  /// EventCarType.carClass exclusive
  final bool withDC;

  /// The url of this car/class. This can be it's wiki page or a download page, for example.
  final String? url;

  /// This car/class's display name.
  String get displayName {
    switch (type) {
      case EventCarType.carClass:
        if (stockOnly) {
          return ((withDC) ? "Stock " : "Stock (non-DC) ") + name + " cars";
        } else {
          return (toBeginningOfSentenceCase(name) ?? "Some") + " cars";
        }
      case EventCarType.car:
        return name;
      default:
        return name;
    }
  }

  /// Whether this entry is a car, as opposed to a class.
  bool get isCar => (type == EventCarType.car);

  EventCar({
    required this.type,
    required this.name,
    required this.stockOnly,
    required this.withDC,
    required this.url,
  });

  factory EventCar.carClass(String name, {bool stockOnly = false, bool withDC = true, String? url}) => EventCar(
        type: EventCarType.carClass,
        name: name,
        stockOnly: stockOnly,
        withDC: withDC,
        url: url,
      );

  factory EventCar.car(String name, {String? url}) => EventCar(
        type: EventCarType.car,
        name: name,
        stockOnly: false,
        withDC: true,
        url: url,
      );

  factory EventCar.fromJson(Map<String, dynamic> json) {
    return EventCar(
      type: _parseCarType(json['type']),
      name: json['name'],
      stockOnly: json['stockOnly'],
      withDC: json['withDC'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _carTypeToString(this.type),
      'name': this.name,
      'stockOnly': this.stockOnly,
      'withDC': this.withDC,
      'url': this.url,
    };
  }
}

enum EventCarType {
  carClass,
  car,
}

EventCarType _parseCarType(String? value) {
  switch (value?.toLowerCase()) {
    case "carclass":
      return EventCarType.carClass;
    case "car":
      return EventCarType.car;
    default:
      return EventCarType.car;
  }
}

String _carTypeToString(EventCarType type) {
  switch (type) {
    case EventCarType.carClass:
      return "carClass";
    case EventCarType.car:
      return "car";
  }
}
