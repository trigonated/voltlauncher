/// An entry of an event's tracklist.
class EventTrack {
  /// The name of the track.
  final String name;

  /// The number of laps.
  final int? laps;

  /// The amount of minutes (e.g. for battle tag)
  final int? minutes;

  /// Whether the track is reversed.
  final bool reverse;

  /// Whether the track is mirrored.
  final bool mirrored;

  /// Whether pickups are enabled.
  final bool? pickups;

  /// The display name of the track. This adds (R) and (M) when appropriate.
  String get displayName => name + ((reverse) ? " (R)" : "") + ((mirrored) ? " (M)" : "");

  EventTrack({
    required this.name,
    this.laps,
    this.minutes,
    this.reverse = false,
    this.mirrored = false,
    this.pickups = false,
  });

  factory EventTrack.fromJson(Map<String, dynamic> json) {
    return EventTrack(
      name: json['name'],
      laps: json['laps'],
      minutes: json['minutes'],
      reverse: json['reverse'],
      mirrored: json['mirrored'],
      pickups: json['pickups'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'laps': this.laps,
      'minutes': this.minutes,
      'reverse': this.reverse,
      'mirrored': this.mirrored,
      'pickups': this.pickups,
    };
  }
}
