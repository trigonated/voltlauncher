// ignore_for_file: non_constant_identifier_names

/// Represents the various assets of the application.
abstract class Assets {
  /// Assets in the "graphics" folder.
  static _GraphicsAssets graphics = _GraphicsAssets();
}

class _GraphicsAssets {
  static const String _prefix = "graphics/";
  final String logo = _prefix + "logo" + ".png";
  final String background_default = _prefix + "background_default" + ".png";
  final String class_default = _prefix + "class_default" + ".png";
  final String car_default = _prefix + "car_default" + ".png";
  final String track_default = _prefix + "track_default" + ".png";
  final String profile_default = _prefix + "profile_default" + ".png";
  final String source_default = _prefix + "source_default" + ".png";

  /// Assets in the "graphics/events" folder.
  _GraphicsEventsAssets events = _GraphicsEventsAssets();

  /// Assets in the "graphics/presets" folder.
  _GraphicsPresetsAssets presets = _GraphicsPresetsAssets();

  /// Assets in the "graphics/news" folder.
  _GraphicsNewsAssets news = _GraphicsNewsAssets();
}

class _GraphicsEventsAssets {
  /// The folder.
  static const String _prefix = "graphics/events/";

  /// The variants of the default event image
  static const List<String> _event_default_variants = [
    _prefix + "event_default" + ".png",
    _prefix + "event_default2" + ".png",
    _prefix + "event_default3" + ".png",
    _prefix + "event_default4" + ".png",
  ];

  /// Placeholder image for images still loading.
  final String event_loading = _prefix + "event_loading" + ".png";

  /// Get a default event image. [index] wraps around so it's always valid.
  String event_default(int index) => _event_default_variants[index % _event_default_variants.length];

  /// Get the image corresponding to a track id (e.g. nhood1, market2, etc...)
  String event_(String level) => _prefix + "event_$level.png";

  /// Get the image corresponding to a track name (e.g. Supermarket 2, Toy World 1, etc...)
  String? forTrackName(String trackname) {
    String? level = _stockLevels[trackname.toLowerCase().trim()];
    return (level != null) ? event_(level) : null;
  }

  static const Map<String, String> _stockLevels = {
    "toys in the hood 1": "nhood1",
    "supermarket 2": "market2",
    "museum 2": "muse2",
    "botanical garden": "garden1",
    "toy world 1": "toylite",
    "ghost town 1": "wild_west1",
    "toy world 2": "toy2",
    "toys in the hood 2": "nhood2",
    "toytanic 1": "ship1",
    "museum 1": "muse1",
    "supermarket 1": "market1",
    "ghost town 2": "wild_west2",
    "toytanic 2": "ship2",
  };
}

class _GraphicsPresetsAssets {
  /// The folder.
  static const String _prefix = "graphics/presets/";

  final String preset_default = _prefix + "preset_default" + ".png";

  final String preset_loading = _prefix + "preset_loading" + ".png";

  final String preset_clone = _prefix + "preset_clone.png";

  final String preset_empty = _prefix + "preset_empty.png";

  String preset_(String name) => _prefix + "preset_$name.png";

  /// Get the image from a specially-formatted url (e.g. "default:classic").
  /// If the url is not a special "default" url or if the image doesn't exist, `null` is returned.
  String? fromDefaultUrl(String url) {
    if (url.startsWith("default:")) {
      String name = url.substring("default:".length).toLowerCase();
      switch (name) {
        case "classic": // Classic
        case "classic_noost": // Classic (without soundtrack)
        case "clone": // Clone existing profile
        case "empty": // Empty profile
          return preset_(name);
        default:
          return null;
      }
    } else {
      return null;
    }
  }
}

class _GraphicsNewsAssets {
  /// The folder.
  static const String _prefix = "graphics/news/";

  /// The variants of the default news image
  static const List<String> _news_default_variants = [
    _prefix + "news_default" + ".png",
    _prefix + "news_default2" + ".png",
    _prefix + "news_default3" + ".png",
    _prefix + "news_default4" + ".png",
  ];

  /// Placeholder image for images still loading.
  final String news_loading = _prefix + "news_loading" + ".png";

  /// Get a default news image. [index] wraps around so it's always valid.
  String news_default(int index) => _news_default_variants[index % _news_default_variants.length];
}
