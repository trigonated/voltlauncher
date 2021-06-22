import 'package:voltlauncher/main.dart';

/// The app's settings.
class AppSettings {
  String? _defaultProfile;

  /// The default profile when the app opens.
  String? get defaultProfile => _defaultProfile;
  set defaultProfile(String? profile) {
    _defaultProfile = profile;
    repository.saveSettings();
  }

  late bool _closeOnPlay;

  /// Whether to close the launcher when starting the game.
  bool get closeOnPlay => _closeOnPlay;
  set closeOnPlay(bool value) {
    _closeOnPlay = value;
    repository.saveSettings();
  }

  late bool _useCustomWindowFrame;

  /// Whether to use the custom window frame.
  bool get useCustomWindowFrame => _useCustomWindowFrame;
  set useCustomWindowFrame(bool value) {
    _useCustomWindowFrame = value;
    repository.saveSettings();
  }

  late bool _useFancyHome;

  /// Whether to use the fancy or the simple home page.
  bool get useFancyHome => _useFancyHome;
  set useFancyHome(bool value) {
    _useFancyHome = value;
    repository.saveSettings();
  }

  AppSettings({
    required String? defaultProfile,
    required bool closeOnPlay,
    required bool useCustomWindowFrame,
    required bool useFancyHome,
  }) {
    _defaultProfile = defaultProfile;
    _closeOnPlay = closeOnPlay;
    _useCustomWindowFrame = useCustomWindowFrame;
    _useFancyHome = useFancyHome;
  }

  factory AppSettings.defaultSettings({String? defaultProfile}) {
    return AppSettings(
      defaultProfile: defaultProfile,
      closeOnPlay: false,
      useCustomWindowFrame: true,
      useFancyHome: false,
    );
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      defaultProfile: json['defaultProfile'],
      closeOnPlay: json['closeOnPlay'] ?? false,
      useCustomWindowFrame: json['useCustomWindowFrame'] ?? true,
      useFancyHome: json['useFancyHome'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultProfile': this.defaultProfile,
      'closeOnPlay': this.closeOnPlay,
      'useCustomWindowFrame': this.useCustomWindowFrame,
      'useFancyHome': this.useFancyHome,
    };
  }
}
