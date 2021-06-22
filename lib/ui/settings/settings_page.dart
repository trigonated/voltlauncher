import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/groups_page.dart';
import 'package:voltlauncher/ui/misc/window/mainwindowpage.dart';
import 'package:window_control/window_control.dart';

/// App settings page.
class SettingsPage extends MainWindowPage {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends MainWindowPageState {
  Widget buildWindowTitleContent(BuildContext context) => buildSimpleWindowTitleContent(context, "Volt Launcher Settings");

  @override
  Widget buildContent(BuildContext context) {
    return _SettingsPageContent();
  }
}

class _SettingsPageContent extends GroupsPage {
  @override
  _SettingsPageContentState createState() => _SettingsPageContentState();
}

class _SettingsPageContentState extends GroupsPageState<_SettingsPageContent> with SingleTickerProviderStateMixin {
  late CheckboxState _useFancyHome;
  late CheckboxState _closeOnPlay;
  late CheckboxState _useCustomWindowFrame;
  late Future<List<ContentSource>> _sources;
  late Future<List<String>> _installs;

  @override
  void initState() {
    super.initState();

    _useFancyHome = CheckboxState(this, initialValue: appSettings.useFancyHome, enabled: false, onChanged: (v) => appSettings.useFancyHome = v);
    _closeOnPlay = CheckboxState(this, initialValue: appSettings.closeOnPlay, onChanged: (v) => appSettings.closeOnPlay = v);
    _useCustomWindowFrame = CheckboxState(
      this,
      initialValue: appSettings.useCustomWindowFrame,
      enabled: (WindowControl.isSupported),
      onChanged: (v) {
        appSettings.useFancyHome = v;
        setState(() {
          if (v) {
            WindowControl.hideTitleBar();
          } else {
            WindowControl.showTitleBar();
          }
        });
      },
    );

    _sources = repository.sources.fetchSources(expanded: true);
    _installs = repository.local.fetchInstalls();
  }

  void refresh({bool deselectSource = false, bool deselectInstall = false}) {
    super.refresh(deselectSource: deselectSource, deselectInstall: deselectInstall);
    setState(() {
      _sources = repository.sources.fetchSources(expanded: true); // This is not done by the user, so no refresh param
      _installs = repository.local.fetchInstalls();
    });
  }

  @override
  List<Widget> buildGroups(BuildContext context) {
    return [
      _buildGeneralGroup(context),
      _buildContentsGroup(context),
    ];
  }

  /// "General" group
  Widget _buildGeneralGroup(BuildContext context) {
    return buildGroup(
      context,
      title: "General",
      children: [
        // Home
        buildCheckboxListGroupRow(
          context,
          title: "Home:",
          items: [
            CheckboxListItem(title: "Use fancy home screen", state: this._useFancyHome),
            CheckboxListItem(title: "Close launcher on play", state: this._closeOnPlay),
          ],
        ),
        // Window
        buildCheckboxListGroupRow(
          context,
          title: "Window:",
          items: [
            CheckboxListItem(title: "Use custom window frame", state: this._useCustomWindowFrame),
          ],
        ),
      ],
    );
  }

  /// "Contents" group
  Widget _buildContentsGroup(BuildContext context) {
    // Contents
    return buildGroup(
      context,
      title: "Contents",
      children: [
        buildSourcesManagementGroupRow(context, title: "Installed sources:", sources: this._sources),
        SizedBox(height: 32),
        buildInstallsManagementGroupRow(context, title: "Installs:", installs: this._installs)
      ],
    );
  }
}
