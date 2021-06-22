/// A content requirement of an event.
class EventContentRequirement {
  /// The type of requirement (pack, car, track).
  final EventContentRequirementType type;

  /// The name of the pack, car, track.
  final String name;

  /// The version of the pack required.
  ///
  /// Only for packs.
  final String? version;

  EventContentRequirement({
    required this.type,
    required this.name,
    this.version,
  });

  factory EventContentRequirement.pack(String name, {String? version}) =>
      EventContentRequirement(type: EventContentRequirementType.pack, name: name, version: version);

  factory EventContentRequirement.car(String name) => EventContentRequirement(type: EventContentRequirementType.car, name: name);

  factory EventContentRequirement.track(String name) => EventContentRequirement(type: EventContentRequirementType.track, name: name);

  factory EventContentRequirement.fromJson(Map<String, dynamic> json) {
    return EventContentRequirement(
      type: _parseEventContentRequirementType(json['type']),
      name: json['name'],
      version: json['version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _eventContentRequirementTypeToString(this.type),
      'name': this.name,
      'version': this.version,
    };
  }
}

enum EventContentRequirementType {
  pack,
  car,
  track,
}

EventContentRequirementType _parseEventContentRequirementType(String? value) {
  switch (value?.toLowerCase()) {
    case "pack":
      return EventContentRequirementType.pack;
    case "car":
      return EventContentRequirementType.car;
    case "track":
      return EventContentRequirementType.track;
    default:
      return EventContentRequirementType.track;
  }
}

String _eventContentRequirementTypeToString(EventContentRequirementType type) {
  switch (type) {
    case EventContentRequirementType.pack:
      return "pack";
    case EventContentRequirementType.car:
      return "car";
    case EventContentRequirementType.track:
      return "track";
  }
}
