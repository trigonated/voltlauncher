import 'dart:async';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/show_in_file_explorer.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/ui/misc/actionbutton.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/sourceindicator.dart';

class ProfilePacksSidePanel extends StatefulWidget {
  final Pack? pack;

  ProfilePacksSidePanel({Key? key, required this.pack}) : super(key: key);

  @override
  _ProfilePacksSidePanelState createState() => _ProfilePacksSidePanelState();
}

class _ProfilePacksSidePanelState extends State<ProfilePacksSidePanel> {
  StreamSubscription<bool>? longTasksSubscription;
  StreamSubscription<double>? installingTaskSubscription;
  StreamSubscription<double>? updatingTaskSubscription;
  StreamSubscription<double>? uninstallingTaskSubscription;

  @override
  void initState() {
    super.initState();

    _subscribeStreams();
  }

  void _subscribeStreams() {
    this.longTasksSubscription?.cancel();
    this.longTasksSubscription = repository.longTasksStream.listen((event) {
      setState(() {
        _subscribeStreams();
      });
    });
    this.installingTaskSubscription?.cancel();
    this.installingTaskSubscription = widget.pack?.installingTask?.progressStream.listen((event) {
      setState(() {});
    });
    this.updatingTaskSubscription?.cancel();
    this.updatingTaskSubscription = widget.pack?.updatingTask?.progressStream.listen((event) {
      setState(() {});
    });
    this.uninstallingTaskSubscription?.cancel();
    this.uninstallingTaskSubscription = widget.pack?.uninstallingTask?.progressStream.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();

    this.longTasksSubscription?.cancel();
    this.installingTaskSubscription?.cancel();
    this.updatingTaskSubscription?.cancel();
    this.uninstallingTaskSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pack == null) return Center(child: Text("Select an pack on the left"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          foregroundDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: _buildImage(context),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              // Content provider
              _buildContentProviderRow(context),
              SizedBox(height: 8),
              // Name
              _buildNameRow(context),
              // Version and action
              SizedBox(height: 16),
              _buildVersionRow(context),
              // Description
              SizedBox(height: 16),
              _buildDescriptionRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Container(
        color: _getColor(),
        child: Icon((widget.pack!.isLocal) ? Icons.folder : Icons.extension, size: 64),
      ),
    );
  }

  Widget _buildContentProviderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (widget.pack!.source != null) ? SourceIndicator(source: widget.pack!.source!) : SizedBox.shrink(),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: _buildContentProviderRowOptionsButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContentProviderRowOptionsButton(BuildContext context) {
    List<ActionPopupMenuItem> menuItems = [
      ActionPopupMenuItem(
        enabled: ((widget.pack!.isInstalled) && ((widget.pack!.location.existsSync()))),
        child: Text("Open in file explorer"),
        onSelected: () => ShowInFileExplorer.showDirectoryInFileExplorer(widget.pack!.location),
      ),
    ];
    return PopupMenuButton<int>(
      child: Icon(Icons.more_vert, size: 16),
      itemBuilder: (context) => menuItems,
      onSelected: (value) => menuItems.firstWhere((e) => e.value == value).onSelected?.call(),
    );
  }

  Widget _buildNameRow(BuildContext context) {
    return Text(
      widget.pack!.name,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildVersionRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Version: ", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Expanded(
          child: Text(widget.pack!.installedVersion ?? widget.pack!.latestVersion ?? "N/A", style: TextStyle(fontSize: 14)),
        ),
        _buildActionColumn(context),
      ],
    );
  }

  Widget _buildActionColumn(BuildContext context) {
    return Container(
      width: 80,
      child: _buildActionWidget(context, pack: widget.pack!),
    );
  }

  Widget _buildActionWidget(BuildContext context, {required Pack pack}) {
    if (pack.isUpdateAvailable) {
      return ActionButton(
        child: Text("Update"),
        showProgress: pack.isUpdating,
        progressText: "Updating",
        progress: widget.pack!.updatingTask?.progress ?? 0,
        onPressed: () => repository.packs.updatePack(pack),
      );
    } else if (pack.isInstalled) {
      if (pack.isEnabled) {
        return ActionButton(
          child: Text("Remove"),
          showProgress: pack.isUninstalling,
          progressText: "Uninstalling",
          progress: widget.pack!.uninstallingTask?.progress ?? 0,
          popupMenuItems: [
            ActionPopupMenuItem(
              child: Text("Disable for this profile"),
              onSelected: () => repository.currentProfile?.disablePack(pack),
            ),
            ActionPopupMenuItem(
              child: Text("Uninstall"),
              onSelected: () => repository.packs.uninstallPack(pack),
            ),
          ],
        );
      } else {
        return ActionButton(
          child: Text("Enable"),
          onPressed: () => repository.currentProfile?.enablePack(pack),
        );
      }
    } else {
      return ActionButton(
        child: Text("Install"),
        showProgress: pack.isInstalling,
        progressText: "Installing",
        progress: widget.pack!.installingTask?.progress ?? 0,
        onPressed: () => repository.packs.installPack(pack),
      );
    }
  }

  Widget _buildDescriptionRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Description", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Text(widget.pack!.description ?? "No description", style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Color _getColor() {
    List<MaterialColor> colors = [
      Colors.pink,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lime,
      Colors.green,
      Colors.teal,
      Colors.cyan,
      Colors.blue,
      Colors.purple,
      Colors.brown,
    ];
    return colors[(widget.pack!.name.length + (widget.pack!.description?.length ?? 0)) % colors.length].shade900;
  }
}
