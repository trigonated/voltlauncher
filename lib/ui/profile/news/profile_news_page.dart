import 'dart:async';
import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/stringutils.dart';
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/listview_with_toolbar.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/maincontenttoolbar.dart';
import 'package:voltlauncher/ui/misc/newsimage.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/sidepanellayout.dart';
import 'package:voltlauncher/ui/misc/large_card_list_item.dart';
import 'package:voltlauncher/ui/profile/news/profile_news_sidepanel.dart';
import 'package:voltlauncher/ui/profile/profile_page.dart';

class ProfileNewsPage extends StatefulWidget {
  @override
  _ProfileNewsPageState createState() => _ProfileNewsPageState();
}

class _ProfileNewsPageState extends State<ProfileNewsPage> {
  late Future<List<NewsItem>> _items;
  NewsItem? _selectedItem;

  @override
  void initState() {
    super.initState();
    _items = repository.news.fetchNews();
    _selectedItem = null;
  }

  void _refresh() {
    setState(() {
      _items = repository.news.fetchNews(refresh: true);
      _selectedItem = null;
    });
  }

  void _manageSources() {
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
      child: FutureBuilder<List<NewsItem>>(
        future: _items,
        builder: (context, snapshot) {
          if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
            return SidePanelLayout(
              mainContent: _buildMainContent(context, snapshot.data!),
              sidePanelHasContent: (_selectedItem != null),
              sidePanelContent: _buildSidePanelContent(context, _selectedItem),
            );
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, List<NewsItem> data) {
    return ListViewWithToolbar.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
      shrinkWrap: true,
      toolbar: _buildMainContentToolbar(context),
      itemCount: data.length,
      itemBuilder: (BuildContext context, int index) => _buildMainContentItem(context, itemIndex: index, item: data[index]),
    );
  }

  Widget _buildMainContentToolbar(BuildContext context) {
    return MainContentToolbar(
      children: [
        MainContentToolbarItem.expandedSpace(),
        MainContentToolbarItem.button(icon: Icons.refresh, tooltip: "Refresh", onPressed: () => _refresh()),
        MainContentToolbarItem.menuButton(menuItems: [
          ActionPopupMenuItem(child: Text("Manage sources"), onSelected: () => _manageSources()),
        ]),
      ],
    );
  }

  Widget _buildMainContentItem(BuildContext context, {required int itemIndex, required NewsItem item}) {
    return Container(
      margin: EdgeInsets.only(top: 24),
      height: 192,
      child: LargeCardListItem(
        image: NewsImage(newsItem: item),
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

  Widget _buildSidePanelContent(BuildContext context, NewsItem? selectedItem) {
    return ProfileNewsSidePanel(newsItem: selectedItem);
  }
}
