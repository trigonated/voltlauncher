import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/stringutils.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/eventimage.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/listview_with_toolbar.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/maincontenttoolbar.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/sidepanellayout.dart';
import 'package:voltlauncher/ui/profile/events/profile_events_sidepanel.dart';
import 'package:voltlauncher/ui/misc/large_card_list_item.dart';
import 'package:voltlauncher/ui/profile/profile_page.dart';

/// "Events" tab of the profile page.
class ProfileEventsPage extends StatefulWidget {
  @override
  _ProfileEventsPageState createState() => _ProfileEventsPageState();
}

class _ProfileEventsPageState extends State<ProfileEventsPage> {
  /// The list of events.
  late Future<List<Event>> _upcomingEvents;

  /// The selected event.
  Event? _selectedItem;

  @override
  void initState() {
    super.initState();
    _upcomingEvents = repository.events.fetchUpcomingEvents();
    _selectedItem = null;
  }

  /// Refresh the data.
  void _refresh() {
    setState(() {
      _upcomingEvents = repository.events.fetchUpcomingEvents(refresh: true);
      _selectedItem = null;
    });
  }

  /// Called when the "Manage sources" menu item is selected.
  void _manageSources() {
    // Navigate to the profile options tab.
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            defaultTab: ProfilePageTab.options,
          ),
        ),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Event>>(
        future: _upcomingEvents,
        builder: (context, snapshot) {
          if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
            // Data is loaded

            return SidePanelLayout(
              mainContent: _buildMainContent(context, snapshot.data!),
              sidePanelHasContent: (_selectedItem != null),
              sidePanelContent: _buildSidePanelContent(context, _selectedItem),
            );
          } else if (snapshot.hasError) {
            // Error
            return Text("${snapshot.error}");
          } else {
            // Loading
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  /// Build the main content (shown on the left).
  Widget _buildMainContent(BuildContext context, List<Event> data) {
    return ListViewWithToolbar.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
      shrinkWrap: true,
      toolbar: _buildMainContentToolbar(context),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) => _buildMainContentItem(context, itemIndex: index, item: data[index]),
    );
  }

  /// Build the toolbar for the main content.
  Widget _buildMainContentToolbar(BuildContext context) {
    return MainContentToolbar(
      children: [
        // Space
        MainContentToolbarItem.expandedSpace(),
        // Refresh
        MainContentToolbarItem.button(icon: Icons.refresh, tooltip: "Refresh", onPressed: () => _refresh()),
        // Menu
        MainContentToolbarItem.menuButton(menuItems: [
          ActionPopupMenuItem(child: Text("Manage sources"), onSelected: () => _manageSources()),
        ]),
      ],
    );
  }

  /// Build a list item for the main content
  Widget _buildMainContentItem(BuildContext context, {required int itemIndex, required Event item}) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      height: 192,
      child: LargeCardListItem(
        image: EventImage(event: item),
        title: item.title,
        subtitle: StringUtils.generatePrettyDate(item.date),
        description: item.description ?? "No description",
        source: item.source,
        onTap: () => setState(
          () => this._selectedItem = item,
        ),
      ),
    );
  }

  /// Build the content of the side panel.
  Widget _buildSidePanelContent(BuildContext context, Event? selectedItem) {
    return ProfileEventsSidePanel(event: selectedItem);
  }
}
