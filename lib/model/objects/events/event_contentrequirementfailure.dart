import 'package:voltlauncher/model/objects/events/event_contentrequirement.dart';

/// A failure to fulfill an event's content requirement.
class EventContentRequirementFailure {
  /// The type of content.
  final EventContentRequirementType type;

  /// The name of the content.
  final String name;

  /// The pack's required version.
  final String? requiredVersion;

  /// The installed version of the pack.
  final String? installedVersion;

  EventContentRequirementFailure({
    required this.type,
    required this.name,
    this.requiredVersion,
    this.installedVersion,
  });

  factory EventContentRequirementFailure.missingPack(String name) => EventContentRequirementFailure(
        type: EventContentRequirementType.pack,
        name: name,
      );

  factory EventContentRequirementFailure.outdatedPack({required String name, required String? requiredVersion, required String? installedVersion}) =>
      EventContentRequirementFailure(
        type: EventContentRequirementType.pack,
        name: name,
        requiredVersion: requiredVersion,
        installedVersion: installedVersion,
      );

  factory EventContentRequirementFailure.missingCar(String name) => EventContentRequirementFailure(
        type: EventContentRequirementType.car,
        name: name,
      );

  factory EventContentRequirementFailure.missingTrack(String name) => EventContentRequirementFailure(
        type: EventContentRequirementType.track,
        name: name,
      );

  static final int Function(EventContentRequirementFailure a, EventContentRequirementFailure b) compareByType = (a, b) {
    // Sort by update required
    if ((a.installedVersion != null) && (b.installedVersion == null)) {
      return -1;
    } else if ((a.installedVersion == null) && (b.installedVersion != null)) {
      return 1;
    }
    // Sort by type
    int aValue = EventContentRequirementType.values.indexOf(a.type);
    int bValue = EventContentRequirementType.values.indexOf(b.type);
    if (aValue != bValue) {
      return aValue.compareTo(bValue);
    }
    // Sort by name
    return a.name.compareTo(b.name);
  };
}
