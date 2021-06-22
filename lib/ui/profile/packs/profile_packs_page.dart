import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/file_picker.dart';
import 'package:voltlauncher/misc/headedlist.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/listview_with_toolbar.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/maincontenttoolbar.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/sidepanellayout.dart';
import 'package:voltlauncher/ui/profile/packs/profile_packs_pack_item.dart';
import 'package:voltlauncher/ui/profile/packs/profile_packs_sidepanel.dart';
import 'package:voltlauncher/ui/profile/profile_page.dart';

class ProfilePacksPage extends StatefulWidget {
  ProfilePacksPage({Key? key}) : super(key: key);

  @override
  _ProfilePacksPageState createState() => _ProfilePacksPageState();
}

class _ProfilePacksPageState extends State<ProfilePacksPage> {
  StreamSubscription<bool>? packsSubscription;
  late Future<List<Pack>> _packs;
  late Pack? _selectedItem;
  late TextEditingController _filterController;

  String get filter => _filterController.text;

  @override
  void initState() {
    super.initState();

    this.packsSubscription = repository.packs.packsStream.listen((event) {
      setState(() {});
    });

    _packs = repository.packs.fetchPacks();
    _selectedItem = null;
    _filterController = TextEditingController(text: "");
    _filterController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();

    this.packsSubscription?.cancel();
  }

  void _refresh() {
    setState(() {
      _packs = repository.packs.fetchPacks(refresh: true);
      _selectedItem = null;
    });
  }

  void _installFromZip() async {
    final File? archiveFile = await FilePicker.showArchivePicker();
    if (archiveFile != null) {
      setState(() {
        repository.packs.installLocalPack(archiveFile);
      });
    }
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
      child: FutureBuilder<List<Pack>>(
        future: _packs,
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

  Widget _buildMainContent(BuildContext context, List<Pack> data) {
    List<Pack> filteredData = data.where((e) => e.name.contains(filter)).toList();
    HeadedList<Pack> headedList = HeadedList.fromList(filteredData, headers: {
      "Update available": (e) => e.isUpdateAvailable,
      "Installed": (e) => ((e.isInstalled) && (!e.isUpdateAvailable) && (e.isEnabled)),
      "Disabled on this profile": (e) => ((e.isInstalled) && (!e.isUpdateAvailable) && (!e.isEnabled)),
      "Not installed": (e) => !e.isInstalled,
    });

    return ListViewWithToolbar.builder(
        padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
        shrinkWrap: true,
        toolbar: _buildToolbar(context),
        itemCount: headedList.items.length,
        itemBuilder: (BuildContext context, int index) {
          if (headedList.items[index] is HeadedListHeaderItem) {
            return _buildHeaderItem(context, title: (headedList.items[index] as HeadedListHeaderItem).title);
          } else {
            return _buildItem(
              context,
              itemIndex: index,
              style: _getItemStyle(itemIndex: index, items: headedList.items),
              item: filteredData[(headedList.items[index] as HeadedListNormalItem).itemIndex],
            );
          }
        });
  }

  Widget _buildToolbar(BuildContext context) {
    return MainContentToolbar(
      children: [
        MainContentToolbarItem.searchBar(controller: _filterController),
        MainContentToolbarItem.expandedSpace(),
        MainContentToolbarItem.button(icon: Icons.refresh, tooltip: "Refresh", onPressed: () => _refresh()),
        MainContentToolbarItem.menuButton(menuItems: [
          ActionPopupMenuItem(child: Text("Install from .zip"), onSelected: () => _installFromZip()),
          ActionPopupMenuItem(child: Text("Manage sources"), onSelected: () => _manageSources()),
        ]),
      ],
    );
  }

  Widget _buildHeaderItem(BuildContext context, {required String title}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 2),
      child: Text(title),
    );
  }

  Widget _buildItem(BuildContext context, {required int itemIndex, required Pack item, required ProfilePacksPackItemStyle style}) {
    return Container(
      margin: EdgeInsets.only(top: (itemIndex > 0) ? 1 : 0),
      height: 48,
      child: ProfilePacksPackItem(
        pack: item,
        style: style,
        onTap: (p) => setState(() {
          _selectedItem = p;
        }),
      ),
    );
  }

  ProfilePacksPackItemStyle _getItemStyle({required int itemIndex, required List<HeadedListItem> items}) {
    bool isFirstOfGroup = (items[itemIndex - 1] is HeadedListHeaderItem);
    bool isLastOfGroup = ((itemIndex == items.length - 1) || (items[itemIndex + 1] is HeadedListHeaderItem));
    return ((isFirstOfGroup) && (isLastOfGroup))
        ? ProfilePacksPackItemStyle.single
        : (isFirstOfGroup)
            ? ProfilePacksPackItemStyle.first
            : (isLastOfGroup)
                ? ProfilePacksPackItemStyle.last
                : ProfilePacksPackItemStyle.middle;
  }

  Widget _buildSidePanelContent(BuildContext context, Pack? selectedItem) {
    return ProfilePacksSidePanel(pack: selectedItem);
  }
}
