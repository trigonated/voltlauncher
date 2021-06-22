import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/ui/profile/home/fancy/profile_home_event_item.dart';
import 'package:voltlauncher/ui/profile/home/fancy/profile_home_event_item_small.dart';
import 'package:voltlauncher/ui/profile/home/fancy/profile_home_news_item_small.dart';
import 'package:voltlauncher/ui/profile/home/profile_home_page_content.dart';

/// "Fancy" (dynamic) home page content.
class ProfileHomePageFancyContent extends StatefulWidget {
  @override
  _ProfileHomePageFancyContentState createState() => _ProfileHomePageFancyContentState();
}

class _ProfileHomePageFancyContentState extends ProfileHomePageContentState<ProfileHomePageFancyContent> {
  late Future<_ProfileHomePageFancyContentData> _data;

  @override
  void initState() {
    super.initState();

    _data = fetchData();
  }

  /// Fetch the data for the page.
  Future<_ProfileHomePageFancyContentData> fetchData() async {
    List<Event> upcomingEvents = await repository.events.fetchUpcomingEvents();
    Event? featuredEvent = upcomingEvents.firstOrNull;
    List<NewsItem> news = await repository.news.fetchNews();
    return _ProfileHomePageFancyContentData(
      featuredEvent: featuredEvent,
      upcomingEvents: upcomingEvents,
      news: news,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMainContent(context),
        _buildBottomBar(context),
      ],
    );
  }

  /// Build the main content, consisting of various columns with data.
  Widget _buildMainContent(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: FutureBuilder<_ProfileHomePageFancyContentData>(
          future: _data,
          builder: (context, snapshot) {
            if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
              // Data loaded
              return Row(
                children: [
                  // What's next
                  Expanded(child: _buildMainContentWhatsNextColumn(context, snapshot.data!)),
                  // Upcoming events
                  SizedBox(width: 24),
                  Container(
                    width: 320,
                    child: _buildMainContentUpcomingEventsColumn(context, snapshot.data!),
                  ),
                  // News
                  SizedBox(width: 24),
                  Container(
                    width: 320,
                    child: _buildMainContentNewsColumn(context, snapshot.data!),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // Error
              return Center(child: Text("${snapshot.error}"));
            } else {
              // Loading
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  /// Build the "What's next" column.
  Widget _buildMainContentWhatsNextColumn(BuildContext context, _ProfileHomePageFancyContentData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text("What's next"),
        // Item
        SizedBox(height: 4),
        Expanded(
          child: (data.featuredEvent != null)
              ? ProfileHomeEventItem(event: data.featuredEvent!, onTap: (event) {})
              : _buildNoDataColumnContent(context, text: "No upcoming events"),
        ),
      ],
    );
  }

  /// Build the "Upcoming events" column.
  Widget _buildMainContentUpcomingEventsColumn(BuildContext context, _ProfileHomePageFancyContentData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text("Upcoming events"),
        // Items
        SizedBox(height: 4),
        Expanded(
          child: _buildColumnContent(
            context,
            itemCount: 6,
            builder: (context, index) {
              if ((index + 1) < data.upcomingEvents.length) {
                return ProfileHomeEventItemSmall(event: data.upcomingEvents[index + 1], onTap: (event) {});
              } else {
                return null;
              }
            },
            noDataText: "No upcoming events",
          ),
        ),
      ],
    );
  }

  /// Build the "News" column
  Widget _buildMainContentNewsColumn(BuildContext context, _ProfileHomePageFancyContentData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text("News"),
        // Items
        SizedBox(height: 4),
        Expanded(
          child: _buildColumnContent(
            context,
            itemCount: 6,
            builder: (context, index) {
              if ((index) < data.news.length) {
                return ProfileHomeNewsItemSmall(newsItem: data.news[index], onTap: (newsItem) {});
              } else {
                return null;
              }
            },
            noDataText: "No news",
          ),
        ),
      ],
    );
  }

  /// Build the bottom bar, with a play button and a progress bar.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      // foregroundDecoration: BoxDecoration(
      //   border: Border(top: BorderSide(color: Colors.white24, width: 1)),
      // ),
      padding: EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Play button
          _buildPlayButton(context),
          // Progress bar
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 48, right: 24),
              child: _buildProgressBar(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the "Play" button.
  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.orange, onPrimary: Colors.black),
        child: Text("PLAY", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        onPressed: (this.longTasksProgress == null) ? () => play() : null,
      ),
    );
  }

  /// Build a long tasks progress bar/"Update" button/"No updates available" text widget.
  Widget _buildProgressBar(BuildContext context) {
    if (this.longTasksProgress != null) {
      // Tasks running
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Installing... (${(this.longTasksProgress! * 100.0).floor()}%)"),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: this.longTasksProgress,
          ),
        ],
      );
    } else {
      // No tasks running
      return FutureBuilder<bool>(
        future: this.areUpdatesAvailable,
        builder: (context, snapshot) {
          if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
            // Loaded
            if (snapshot.data!) {
              // Updates available
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("Updates available", style: const TextStyle(color: Colors.white)),
                  SizedBox(width: 16),
                  OutlinedButton(child: Text("Update all"), onPressed: () => updateAll()),
                ],
              );
            } else {
              // No updates available
              return Text("Up-to-date. Ready to play", style: const TextStyle(color: Colors.white24));
            }
          } else if (snapshot.hasError) {
            // Error
            return Text("Couldn't check for updates", style: const TextStyle(color: Colors.white24));
          } else {
            // Loading
            return Text("Checking for updates", style: const TextStyle(color: Colors.white24));
          }
        },
      );
    }
  }

  /// Build the content of a column consisting of a list of items.
  Widget _buildColumnContent(
    BuildContext context, {
    required int itemCount,
    required Widget? Function(BuildContext context, int index) builder,
    required String noDataText,
  }) {
    List<Widget> items = List.empty(growable: true);
    for (var i = 0; i < itemCount; i++) {
      // Add a space on the items after the first
      if (i > 0) {
        items.add(SizedBox(height: 8));
      }
      // Add the item
      items.add(Expanded(child: builder(context, i) ?? SizedBox.shrink()));
    }
    if (items.isNotEmpty) {
      // Has data
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      );
    } else {
      // No data
      return _buildNoDataColumnContent(context, text: noDataText);
    }
  }

  /// Build the content of a column that has no data to show.
  Widget _buildNoDataColumnContent(BuildContext context, {required String text}) {
    return Opacity(
      opacity: 0.25,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black12, boxShadow: [BoxShadow(color: Colors.black38, offset: const Offset(0, 5), blurRadius: 10.0, spreadRadius: 2.0)]),
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Center(child: Text(text)),
          ),
        ),
      ),
    );
  }
}

/// The data used on the fancy page.
class _ProfileHomePageFancyContentData {
  Event? featuredEvent;
  List<Event> upcomingEvents;
  List<NewsItem> news;

  _ProfileHomePageFancyContentData({
    required this.featuredEvent,
    required this.upcomingEvents,
    required this.news,
  });
}
