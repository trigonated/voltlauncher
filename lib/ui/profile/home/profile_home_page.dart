import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/maincontenttoolbar.dart';
import 'package:voltlauncher/ui/profile/home/fancy/profile_home_page_fancy_content.dart';
import 'package:voltlauncher/ui/profile/home/simple/profile_home_page_simple_content.dart';

/// "Home" tab of the profile page.
/// 
/// This page has two different UIs depending on the user
/// settings: a simple and a "fancy" homescreen.
class ProfileHomePage extends StatefulWidget {
  @override
  _ProfileHomePageState createState() => _ProfileHomePageState();
}

class _ProfileHomePageState extends State<ProfileHomePage> {
  late bool _useFancyHome;

  @override
  void initState() {
    super.initState();

    _useFancyHome = repository.appSettings.useFancyHome;
  }

  void _toogleFancyHome() {
    setState(() {
      _useFancyHome = !_useFancyHome;
      repository.appSettings.useFancyHome = _useFancyHome;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(context),
          // Content
          Expanded(
            child: _buildMainContent(context),
          ),
        ],
      ),
    );
  }

  /// Build the toolbar.
  Widget _buildToolbar(BuildContext context) {
    return MainContentToolbar(
      children: [
        MainContentToolbarItem.expandedSpace(),
        // MainContentToolbarItem.button(icon: Icons.refresh, tooltip: "Refresh", onPressed: () => _refresh()),
        MainContentToolbarItem.menuButton(menuItems: [
          ActionPopupMenuItem(
            child: Text((_useFancyHome) ? "Switch to simple view" : "Switch to fancy view"),
            enabled: _useFancyHome,
            onSelected: () => _toogleFancyHome(),
          ),
        ]),
      ],
    );
  }

  /// Build the content of the page.
  Widget _buildMainContent(BuildContext context) {
    if (_useFancyHome) {
      // "Fancy" UI
      return ProfileHomePageFancyContent();
    } else {
      // Simple UI
      return ProfileHomePageSimpleContent();
    }
  }
}
