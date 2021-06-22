import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/eventssource.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';

/// Contains methods to load content sources from remote urls.
abstract class ContentSourceGetter {
  /// Load a Volt Launcher API [ContentSource] from [url].
  ///
  /// For Re-volt IO API sources, use [getRevoltIOContentSource] instead.
  static Future<ContentSource?> getContentSource({required String url}) async {
    Map<String, dynamic>? json = await _downloadJson(url);
    if (json == null) return null;
    try {
      return ContentSource.fromJson(json, universe: null);
    } catch (e) {
      return null;
    }
  }

  /// Load a Re-volt IO API [ContentSource] from [url]. A [name] and a [type] must be provided.
  ///
  /// For Volt Launcher API sources, use [getContentSource] instead.
  static Future<ContentSource?> getRevoltIOContentSource({required String name, required ContentSourceType type, required String url}) async {
    Map<String, dynamic>? json = await _downloadJson(url);
    if (json == null) return null;
    // Parse the downloaded source, depending on the provided type
    switch (type) {
      case ContentSourceType.unknown:
        return null;
      case ContentSourceType.universe:
        // Non-existing
        return null;
      case ContentSourceType.repository:
        // Note: Only "third-party" Revolt IO api repos supported
        return _parseRevoltIOPackRepository(name: name, url: url, json: json);
      case ContentSourceType.events_source:
        return _parseRevoltIOEventsSource(name: name, url: url, json: json);
      case ContentSourceType.news_source:
        return _parseRevoltIONewsSource(name: name, url: url, json: json);
      case ContentSourceType.presets_source:
        // Non-existing
        return null;
    }
  }

  /// Download the json from [url]. If an error occurs, `null` is returned.
  static Future<Map<String, dynamic>?> _downloadJson(String url) async {
    Uri? uri = Uri.tryParse(url);
    if (uri == null) return null;

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Parse the json of a Re-volt IO API pack repository source. If the json is not a valid pack repository source, `null` is returned.
  static PackRepository? _parseRevoltIOPackRepository({required String name, required String url, required Map<String, dynamic> json}) {
    // Check if it contains certain fields
    if ((!json.containsKey("name")) || (!json.containsKey("version")) || (!json.containsKey("packages"))) return null;

    return PackRepository.revoltIO(
      universe: null,
      name: name,
      iconUrl: null,
      url: url,
    );
  }

  /// Parse the json of a Re-volt IO API events source. If the json is not a valid events source, `null` is returned.
  static EventsSource? _parseRevoltIOEventsSource({required String name, required String url, required Map<String, dynamic> json}) {
    // No checking can be done

    return EventsSource.revoltIO(
      universe: null,
      name: name,
      iconUrl: null,
      url: url,
    );
  }

  /// Parse the json of a Re-volt IO API news source. If the json is not a valid news source, `null` is returned.
  static NewsSource? _parseRevoltIONewsSource({required String name, required String url, required Map<String, dynamic> json}) {
    // Check if it contains certain fields
    if ((!json.containsKey("header")) || (!json.containsKey("content")) || (!json.containsKey("children"))) return null;

    return NewsSource.revoltIO(
      universe: null,
      name: name,
      iconUrl: null,
      url: url,
    );
  }
}
