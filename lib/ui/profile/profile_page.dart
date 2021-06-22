import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/ui/misc/profilepickerbutton.dart';
import 'package:voltlauncher/ui/misc/window/mainwindowpage.dart';
import 'package:voltlauncher/ui/profile/events/profile_events_page.dart';
import 'package:voltlauncher/ui/profile/home/profile_home_page.dart';
import 'package:voltlauncher/ui/profile/options/profile_options_page.dart';
import 'package:voltlauncher/ui/profile/packs/profile_packs_page.dart';

import 'news/profile_news_page.dart';

class ProfilePage extends MainWindowPage {
  final ProfilePageTab defaultTab;

  ProfilePage({
    this.defaultTab = ProfilePageTab.home,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends MainWindowPageState with SingleTickerProviderStateMixin {
  late TabController _controller;
  late StreamSubscription<AppProfile?>? currentProfileSubscription;

  @override
  void initState() {
    super.initState();

    _controller = TabController(
      vsync: this,
      length: _tabs.length,
      initialIndex: _profilePageTabToTabIndex((widget as ProfilePage).defaultTab),
    );

    this.currentProfileSubscription = repository.currentProfileStream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    this.currentProfileSubscription?.cancel();
  }

  final List<_Tab> _tabs = List.of([
    _Tab(
      title: "Home",
      build: (context, tab) => ProfileHomePage(),
    ),
    _Tab(
      title: "Events",
      build: (context, tab) => ProfileEventsPage(),
    ),
    _Tab(
      title: "News",
      build: (context, tab) => ProfileNewsPage(),
    ),
    _Tab(
      title: "Packs",
      build: (context, tab) => ProfilePacksPage(),
    ),
    _Tab(
      title: "Profile",
      build: (context, tab) => ProfileOptionsPage(),
    ),
  ]);

  Widget buildWindowTitleContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.all(4),
          child: ProfilePickerButton(),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(8, 0, 0, 0),
          child: TabBar(
            controller: _controller,
            isScrollable: true,
            tabs: _tabs.map((e) => Text(e.title.toUpperCase(), style: TextStyle(fontSize: 14))).toList(),
          ),
        ),
      ],
    );
  }

  Widget buildContent(BuildContext context) {
    return TabBarView(
      controller: _controller,
      children: _tabs.map((e) => Container(child: e.build(context, e))).toList(),
    );
  }
}

class _Tab {
  final String title;
  final Widget Function(BuildContext context, _Tab tab) build;

  _Tab({
    required this.title,
    required this.build,
  });
}

enum ProfilePageTab {
  home,
  events,
  news,
  packs,
  options,
}

int _profilePageTabToTabIndex(ProfilePageTab tab) {
  switch (tab) {
    case ProfilePageTab.home:
      return 0;
    case ProfilePageTab.events:
      return 1;
    case ProfilePageTab.news:
      return 2;
    case ProfilePageTab.packs:
      return 3;
    case ProfilePageTab.options:
      return 4;
  }
}
