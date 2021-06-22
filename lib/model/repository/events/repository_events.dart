import 'dart:async';
import 'dart:convert';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/file_extensions.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/model/apis/revoltio/io_api.dart';
import 'package:voltlauncher/model/apis/revoltio/io_event.dart';
import 'package:voltlauncher/model/objects/events/event_car.dart';
import 'package:voltlauncher/model/objects/events/event_contentrequirement.dart';
import 'package:voltlauncher/model/objects/events/event_contentrequirementfailure.dart';
import 'package:voltlauncher/model/objects/events/event_track.dart';
import 'package:voltlauncher/model/objects/local/local_pack.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/repository/repository.dart';
import 'package:voltlauncher/model/objects/events/event.dart';

class RepositoryEvents {
  /// The parent repository.
  late Repository _repository;

  /// The cache.
  late _RepositoryEventsCache _cache;

  RepositoryEvents(Repository repository) {
    _repository = repository;
    _cache = _RepositoryEventsCache();
  }

  /// Fetch the upcoming events.
  Future<List<Event>> fetchUpcomingEvents({bool refresh = false}) async {
    // Load from cache
    List<Event>? upcomingEvents = (!refresh) ? await this._cache.fetchUpcomingEventsFromCache() : null;

    // Check if there's no cached events (or refresh is true)
    if (upcomingEvents == null) {
      upcomingEvents = [];
      // Get the events sources
      List<EventsSource> sources = await _repository.sources.fetchEventsSources();
      // Load the events from each source
      for (EventsSource source in sources) {
        switch (source.apiType) {
          case EventsSourceApiType.volt:
            // TODO: Handle this case.
            break;
          case EventsSourceApiType.revoltIO:
            List<IOEvent> ioEvents = await IOApi.fetchEvents(source: source, url: source.url);
            upcomingEvents.addAll(ioEvents.map((e) => e.toEvent()).toList());
            break;
        }
      }
      // Update the cache
      this._cache.saveUpcomingEventsToCache(upcomingEvents);
    }

    // Filter out past events (more than 24 hours ago)
    DateTime visiblePastEventsThreshold = DateTime.now().subtract(Duration(hours: 24)).toUtc();
    upcomingEvents = upcomingEvents.where((upcomingEvent) => upcomingEvent.date.isAfter(visiblePastEventsThreshold)).toList();

    // Sort the events by date
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));

    return upcomingEvents;
  }

  /// Check if an [event]'s content requirements are fulfilled.
  ///
  /// Returns a list of "failures", or an empty list of all requirements are fulfilled.
  List<EventContentRequirementFailure> checkEventContentRequirements(Event event) {
    // Load from cache
    List<EventContentRequirementFailure>? cachedResult = this._cache.fetchEventContentRequirementsChecksFromCache(event);
    if (cachedResult != null) {
      return cachedResult;
    }

    List<EventContentRequirementFailure>? result = [];

    // Check the list of requirements
    if (event.requiredContent != null) {
      for (EventContentRequirement requirement in event.requiredContent!) {
        switch (requirement.type) {
          case EventContentRequirementType.pack:
            LocalPack? localPack = repository.local.fetchPackSync(name: requirement.name);
            if (localPack == null) {
              result.add(EventContentRequirementFailure.missingPack(requirement.name));
            } else if ((requirement.version != null) && (localPack.version != requirement.version)) {
              result.add(EventContentRequirementFailure.outdatedPack(
                name: requirement.name,
                requiredVersion: requirement.version!,
                installedVersion: localPack.version,
              ));
            }
            break;
          case EventContentRequirementType.car:
            if (repository.local.fetchCarSync(name: requirement.name) == null) {
              result.add(EventContentRequirementFailure.missingCar(requirement.name));
            }
            break;
          case EventContentRequirementType.track:
            if (repository.local.fetchTrackSync(name: requirement.name) == null) {
              result.add(EventContentRequirementFailure.missingTrack(requirement.name));
            }
            break;
        }
      }
    }
    // Check cars from the allowed cars
    if (event.allowedCars != null) {
      for (EventCar car in event.allowedCars!) {
        // Check if theres no local car with the same name
        if ((car.isCar) && (repository.local.fetchCarSync(name: car.name) == null)) {
          // Check if the car isn't already on the list
          if (!result.any((e) => ((e.type == EventContentRequirementType.car) && (e.name == car.name)))) {
            result.add(EventContentRequirementFailure.missingCar(car.name));
          }
        }
      }
    }
    // Check tracks from the tracklist
    if (event.trackList != null) {
      for (EventTrack track in event.trackList!) {
        // Check if theres no local track with the same name
        if (repository.local.fetchTrackSync(name: track.name) == null) {
          if (!result.any((e) => ((e.type == EventContentRequirementType.track) && (e.name == track.name)))) {
            result.add(EventContentRequirementFailure.missingTrack(track.name));
          }
        }
      }
    }

    // Sort the items by type
    result.sort(EventContentRequirementFailure.compareByType);

    // Update the cache
    this._cache.saveEventContentRequirementsChecksToCache(event, result);

    return result;
  }

  /// Clears the cache.
  void clearCache() => this._cache.clear();
}

class _RepositoryEventsCache {
  List<Event>? _upcomingEvents;
  Map<Event, List<EventContentRequirementFailure>> _eventContentRequirementsChecks = {};

  void clear() {
    LocalDirectories.appData.cache.upcomingEventsFile.deleteIfExists();
    this._upcomingEvents = null;
    this._eventContentRequirementsChecks.clear();
  }

  Future<List<Event>?> fetchUpcomingEventsFromCache() async {
    if (this._upcomingEvents != null) {
      // Data was already loaded
      return this._upcomingEvents;
    } else {
      // Load from the cache file
      if (await LocalDirectories.appData.cache.upcomingEventsFile.exists()) {
        List<dynamic> json = jsonDecode(await LocalDirectories.appData.cache.upcomingEventsFile.readAsString());
        return this._upcomingEvents = (await json.mapAsync((e) async => await Event.fromJson(e))).toList();
      } else {
        return null;
      }
    }
  }

  Future<bool> saveUpcomingEventsToCache(List<Event> events) async {
    this._upcomingEvents = events;

    List<dynamic> json = [];
    json.addAll(events.map((e) => e.toJson()));
    await LocalDirectories.appData.cache.directory.create(recursive: true);
    await LocalDirectories.appData.cache.upcomingEventsFile.writeAsString(JsonEncoder.withIndent('\t').convert(json));
    return true;
  }

  List<EventContentRequirementFailure>? fetchEventContentRequirementsChecksFromCache(Event event) {
    return this._eventContentRequirementsChecks[event];
  }

  void saveEventContentRequirementsChecksToCache(Event event, List<EventContentRequirementFailure> checks) {
    this._eventContentRequirementsChecks[event] = checks;
  }
}
