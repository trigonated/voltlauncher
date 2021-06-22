import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/eventimage.dart';
import 'package:voltlauncher/misc/stringutils.dart';
import 'package:voltlauncher/misc/url_opener.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/model/objects/events/event_car.dart';
import 'package:voltlauncher/model/objects/events/event_lobby.dart';
import 'package:voltlauncher/model/objects/events/event_track.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/sourceindicator.dart';
import 'package:voltlauncher/ui/profile/events/profile_events_car_item.dart';
import 'package:voltlauncher/ui/profile/events/profile_events_track_item.dart';
import 'package:voltlauncher/ui/profile/events/profile_events_unfulfilled_required_content_dialog.dart';

/// Content of the Events Page's side panel.
class ProfileEventsSidePanel extends StatefulWidget {
  final Event? event;

  ProfileEventsSidePanel({Key? key, required this.event}) : super(key: key);

  @override
  _ProfileEventsSidePanelState createState() => _ProfileEventsSidePanelState();
}

class _ProfileEventsSidePanelState extends State<ProfileEventsSidePanel> {
  @override
  void initState() {
    super.initState();
  }

  /// Called when the missing content button is clicked.
  void _showUnfulfilledRequiredContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProfileEventsUnfulfilledRequiredContentDialog(event: widget.event!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event == null) return Center(child: Text("Select an event on the left"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          foregroundDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: EventImage(event: widget.event!),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              // Missing content
              (!widget.event!.isRequiredContentFulfilled) ? _buildUnfulfilledRequiredContentRow(context) : SizedBox.shrink(),
              SizedBox(height: (!widget.event!.isRequiredContentFulfilled) ? 16 : 0),
              // Content provider
              _buildContentProviderRow(context),
              SizedBox(height: 8),
              // Tags
              (widget.event!.tags.isNotEmpty) ? _buildTagsRow(context) : SizedBox.shrink(),
              // Title
              _buildTitleRow(context),
              // Hosts
              (widget.event!.hosts?.isNotEmpty == true) ? _buildHostsRow(context) : SizedBox.shrink(),
              // Time
              SizedBox(height: 16),
              _buildTimeRow(context),
              // Signup button
              SizedBox(height: (widget.event!.signupUrl != null) ? 16 : 0),
              (widget.event!.signupUrl != null) ? _buildSignupRow(context) : SizedBox.shrink(),
              // Lobbies and Join button
              SizedBox(height: (widget.event!.lobbies?.isNotEmpty == true) ? 16 : 0),
              (widget.event!.lobbies?.isNotEmpty == true) ? _buildLobbiesRow(context) : SizedBox.shrink(),
              // Description
              SizedBox(height: 16),
              _buildDescriptionRow(context),
              // Allowed cars
              SizedBox(height: (widget.event!.allowedCars?.isNotEmpty == true) ? 16 : 0),
              (widget.event!.allowedCars?.isNotEmpty == true) ? _buildAllowedCarsRow(context) : SizedBox.shrink(),
              // Track list
              SizedBox(height: (widget.event!.trackList?.isNotEmpty == true) ? 16 : 0),
              (widget.event!.trackList?.isNotEmpty == true) ? _buildTrackListRow(context) : SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  /// Build the row for the missing content.
  Widget _buildUnfulfilledRequiredContentRow(BuildContext context) {
    return ElevatedButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_sharp, color: Colors.yellow, size: 16.0),
          SizedBox(width: 4),
          Text("Missing or outdated content", style: TextStyle(color: Colors.yellow)),
        ],
      ),
      onPressed: () => _showUnfulfilledRequiredContentDialog(),
    );
  }

  /// Build the row with the content provider.
  Widget _buildContentProviderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SourceIndicator(source: widget.event!.source),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildContentProviderRowOptionsButton(context),
          ),
        ),
      ],
    );
  }

  /// Build the menu for the side panel.
  Widget _buildContentProviderRowOptionsButton(BuildContext context) {
    List<ActionPopupMenuItem> menuItems = [
      ActionPopupMenuItem(
        enabled: (widget.event!.url != null),
        child: Text("Open website"),
        onSelected: () => UrlOpener.openUrl(widget.event!.url!),
      ),
    ];
    return PopupMenuButton<int>(
      child: Icon(Icons.more_vert, size: 16),
      itemBuilder: (context) => menuItems,
      onSelected: (value) => menuItems.firstWhere((e) => e.value == value).onSelected?.call(),
    );
  }

  /// Build the row with the tags for the event.
  Widget _buildTagsRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.event!.tags
          .map((e) => Chip(
                label: Text(toBeginningOfSentenceCase(e)!),
              ))
          .toList(),
    );
  }

  /// Build the title row.
  Widget _buildTitleRow(BuildContext context) {
    return Text(
      widget.event!.title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  /// Build the hosts row.
  Widget _buildHostsRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("By: ", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Text(StringUtils.generatePrettyHostsList(widget.event!.hosts!), style: TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Build the row with the event's time.
  Widget _buildTimeRow(BuildContext context) {
    String time = DateFormat.yMMMMd().add_Hm().format(widget.event!.date);
    String prettyTimeAgo = timeago.format(widget.event!.date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("On: ", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Text("$time ($prettyTimeAgo)", style: TextStyle(fontSize: 14)),
      ],
    );
  }

  /// Build the signup button row.
  Widget _buildSignupRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("This event may require a signup", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14)),
        SizedBox(height: 8),
        ElevatedButton(
          child: Text("Open signup page"),
          onPressed: () {
            UrlOpener.openUrl(widget.event!.signupUrl!);
          },
        ),
      ],
    );
  }

  /// Build the lobbies row.
  Widget _buildLobbiesRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Lobbies", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.event!.lobbies!.map((e) => _buildLobbiesRowItem(context, e)).toList(),
        ),
      ],
    );
  }

  /// Build an item of the lobbies row.
  Widget _buildLobbiesRowItem(BuildContext context, EventLobby lobby) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lobby name
          Expanded(
            child: Text(
              (lobby.name ?? "Lobby ${widget.event!.lobbies!.indexOf(lobby) + 1}") + ((lobby.address != null) ? " (${lobby.address})" : ""),
              style: TextStyle(fontSize: 14),
            ),
          ),
          // Join button
          (lobby.address != null)
              ? ElevatedButton(
                  child: Text("Join"),
                  onPressed: () {
                    repository.startGame(lobby: lobby);
                  })
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  /// Build the description row.
  Widget _buildDescriptionRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Description", style: TextStyle(color: Colors.white54, fontSize: 14)),
        MarkdownBody(data: widget.event!.description ?? "No description"),
      ],
    );
  }

  /// Build the car list row.
  Widget _buildAllowedCarsRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Allowed cars", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.event!.allowedCars!.map((e) => _buildAllowedCarsRowItem(context, e)).toList(),
        ),
      ],
    );
  }

  /// Build an item of the car list row.
  Widget _buildAllowedCarsRowItem(BuildContext context, EventCar car) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: ProfileEventsCarItem(car: car),
    );
  }

  /// Build the track list row.
  Widget _buildTrackListRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Track list", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.event!.trackList!.map((e) => _buildTrackListRowItem(context, e)).toList(),
        ),
      ],
    );
  }

  /// Build an item of the track list row.
  Widget _buildTrackListRowItem(BuildContext context, EventTrack track) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 2, 0, 2),
      child: ProfileEventsTrackItem(track: track),
    );
  }
}
