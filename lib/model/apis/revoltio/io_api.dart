import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/model/apis/revoltio/io_event.dart';
import 'package:voltlauncher/model/apis/revoltio/io_eventsdataitem.dart';
import 'package:voltlauncher/model/apis/revoltio/io_newsitem.dart';
import 'package:voltlauncher/model/apis/revoltio/io_pack.dart';
import 'package:voltlauncher/model/apis/revoltio/io_repo.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';

/// Methods to fetch data from sources based on the Re-volt IO API.
class IOApi {
  /// Fetch the list of events from a [url].
  ///
  /// [source] is used to help fill the parsed objects.
  ///
  /// [url] is usually `source.url`. Example: https://re-volt.io/events-data.
  static Future<List<IOEvent>> fetchEvents({required EventsSource source, required String url}) async {
    print("IOApi: Fetching events from $url");
    Uri? uri = Uri.tryParse(url);
    if (uri == null) throw Exception('Failed to load the events from $url (invalid URI)');
    String eventBaseUrl = uri.origin;

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode the json
      Map<String, dynamic> json = jsonDecode(response.body);
      // Parse the list of items
      List<IOEventsDataItem> eventsDataItems = json.keys.map((key) => IOEventsDataItem.fromJson(json[key])).toList();
      // Download and parse the event corresponding to each item
      List<IOEvent> events = [];
      for (IOEventsDataItem eventsDataItem in eventsDataItems) {
        events.add(await IOApi.fetchEvent(source: source, url: eventBaseUrl + eventsDataItem.url));
      }
      return events;
    } else {
      throw Exception('Failed to load the events from $url (${response.statusCode})');
    }
  }

  /// Fetch the an event from a [url].
  ///
  /// [source] is used to help fill the parsed object.
  ///
  /// Example [url]: https://re-volt.io/events/2021-03-11-1900.
  static Future<IOEvent> fetchEvent({required EventsSource source, required String url}) async {
    print("IOApi: \tFetching event from $url");
    Uri? uri = Uri.tryParse(url + "?return-as=json");
    if (uri == null) throw Exception('Failed to load event: $url (invalid URI)');

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode and parse the json
      return IOEvent.fromJson(source: source, url: url, json: jsonDecode(response.body));
    } else {
      throw Exception('Failed to load event: $url (${response.statusCode})');
    }
  }

  /// Fetch the list of news from a [url].
  ///
  /// [source] is used to help fill the parsed objects.
  ///
  /// Example [url]: https://re-volt.io/blog?return-as=json.
  static Future<List<IONewsItem>> fetchNews({required NewsSource source, required String url}) async {
    print("IOApi: Fetching news from $url");
    Uri? uri = Uri.tryParse(url);
    if (uri == null) throw Exception('Failed to load the news from $url (invalid URI)');

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode the json
      Map<String, dynamic> json = jsonDecode(response.body);
      // Parse the news items (items of the "children" json property)
      if (json.containsKey("children")) {
        return (json["children"] as Iterable<dynamic>).mapNotNull((e) => IONewsItem.fromJson(source: source, url: null, json: e)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load the news from $url (${response.statusCode})');
    }
  }

  /// Fetch a news item from a [url].
  ///
  /// [source] is used to help fill the parsed object.
  ///
  /// Example [url]: https://re-volt.io/blog/march-content-pack-update-2021.
  static Future<IONewsItem?> fetchNewsItem({required NewsSource source, required String url}) async {
    print("IOApi: \tFetching news item from $url");
    Uri? uri = Uri.tryParse(url + "?return-as=json");
    if (uri == null) throw Exception('Failed to load news item: $url (invalid URI)');

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode and parse the json
      return IONewsItem.fromJson(source: source, url: url, json: jsonDecode(response.body));
    } else {
      throw Exception('Failed to load news item: $url (${response.statusCode})');
    }
  }

  /// Fetch the list of third-party repositories from a [url].
  ///
  /// [source] is used to help fill the parsed objects.
  ///
  /// Example [url]: https://re-volt.gitlab.io/rvio/repos/repos.json.
  static Future<List<IORepo>> fetchThirdPartyRepositories({required ContentSource source, required String url}) async {
    print("IOApi: Fetching 3rd party repositories from $url");
    Uri? uri = Uri.tryParse(url);
    if (uri == null) throw Exception('Failed to the third-party repositories from $url (invalid URI)');

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode the json
      Map<String, dynamic> json = jsonDecode(response.body);
      // Iterate over the list of repos and fetch each item
      List<String> repoUrls = json['repos']?.map<String>((e) => e as String)?.toList() ?? [];
      List<IORepo> repos = [];
      for (String repoUrl in repoUrls) {
        repos.add(await IOApi.fetchThirdPartyRepository(source: source, url: repoUrl));
      }
      return repos;
    } else {
      throw Exception('Failed to load the third-party repositories from $url (${response.statusCode})');
    }
  }

  /// Fetch a third-party repository.
  ///
  /// Example url: https://re-volt.gitlab.io/rvio/repos/arm.json
  static Future<IORepo> fetchThirdPartyRepository({required ContentSource source, required String url}) async {
    print("IOApi: \tFetching 3rd party repository from $url");
    Uri? uri = Uri.tryParse(url);
    if (uri == null) throw Exception('Failed to load third-party repository: $url (invalid URI)');

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode and parse the json
      return IORepo.fromJson(source: source, url: url, json: jsonDecode(response.body));
    } else {
      throw Exception('Failed to load third-party repository: $url (${response.statusCode})');
    }
  }

  /// Fetch the official repository's packs from a [url].
  ///
  /// [source] is used to help fill the parsed objects.
  ///
  /// Example [url]: https://distribute.re-volt.io/packages.json.
  static Future<List<IOPack>> fetchMainRepositoryPacks({required PackRepository source, required String url}) async {
    print("IOApi: Fetching packs from repository at $url");
    Uri? uri = Uri.tryParse(url);
    if (uri == null) throw Exception('Failed to load packs from repository: $url (invalid URI)');
    String packBaseUrl = "https://distribute.re-volt.io/packs";

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode and parse the packs
      Map<String, dynamic> json = jsonDecode(response.body);
      return json.keys.map((key) => IOPack.fromJson(source: source, name: key, json: json[key], url: "$packBaseUrl/$key.zip")).toList();
    } else {
      throw Exception('Failed to load packs from repository: $url (${response.statusCode})');
    }
  }

  /// Fetch a third-party repository's packs from a [url].
  ///
  /// [source] is used to help fill the parsed objects.
  ///
  /// Example [url]: https://re-volt.gitlab.io/rvio/repos/arm.json.
  static Future<List<IOPack>> fetchThirdPartyRepositoryPacks({required PackRepository source, required String url}) async {
    print("IOApi: Fetching packs from 3rd party repository at $url");
    Uri? uri = Uri.tryParse(url);
    if (uri == null) throw Exception('Failed to load packs from repository: $url (invalid URI)');

    // Download the json
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      // Decode and parse the packs
      return IORepo.fromJson(source: source, url: url, json: jsonDecode(response.body)).packages(source: source);
    } else {
      throw Exception('Failed to load packs from third-party repository: $url (${response.statusCode})');
    }
  }
}
