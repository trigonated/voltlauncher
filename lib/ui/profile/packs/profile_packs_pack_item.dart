import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/actionbutton.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';
import 'package:voltlauncher/ui/misc/translucentcard.dart';

class ProfilePacksPackItem extends StatefulWidget {
  final Pack pack;
  final ProfilePacksPackItemStyle style;
  final void Function(Pack pack) onTap;

  ProfilePacksPackItem({
    Key? key,
    required this.pack,
    this.style = ProfilePacksPackItemStyle.single,
    required this.onTap,
  }) : super(key: key);

  @override
  _ProfilePacksPackItemState createState() => _ProfilePacksPackItemState();
}

class _ProfilePacksPackItemState extends State<ProfilePacksPackItem> {
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
    this.installingTaskSubscription = widget.pack.installingTask?.progressStream.listen((event) {
      setState(() {});
    });
    this.updatingTaskSubscription?.cancel();
    this.updatingTaskSubscription = widget.pack.updatingTask?.progressStream.listen((event) {
      setState(() {});
    });
    this.uninstallingTaskSubscription?.cancel();
    this.uninstallingTaskSubscription = widget.pack.uninstallingTask?.progressStream.listen((event) {
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
    return Opacity(
      opacity: ((!widget.pack.isInstalled) || (widget.pack.isEnabled)) ? 1 : 0.5,
      child: ItemContainer(
        onTap: () => widget.onTap.call(widget.pack),
        child: _buildContent(context),
        margin: const EdgeInsets.all(0),
        borderRadius: (widget.style == ProfilePacksPackItemStyle.first)
            ? const BorderRadius.only(topLeft: TranslucentCard.defaultRadius, topRight: TranslucentCard.defaultRadius)
            : (widget.style == ProfilePacksPackItemStyle.middle)
                ? const BorderRadius.only()
                : (widget.style == ProfilePacksPackItemStyle.last)
                    ? const BorderRadius.only(bottomLeft: TranslucentCard.defaultRadius, bottomRight: TranslucentCard.defaultRadius)
                    : const BorderRadius.all(TranslucentCard.defaultRadius),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildIconColumn(context),
        _buildNameColumn(context),
        _buildDescriptionColumn(context),
        _buildVersionColumn(context),
        _buildActionColumn(context),
      ],
    );
  }

  Widget _buildIconColumn(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Icon(
        (widget.pack.isUpdateAvailable)
            ? Icons.arrow_circle_up
            : (widget.pack.isInstalled)
                ? (widget.pack.isLocal)
                    ? Icons.folder
                    : (widget.pack.isEnabled)
                        ? Icons.extension
                        : Icons.block
                : Icons.extension_outlined,
        color: Colors.white,
        size: 24.0,
      ),
    );
  }

  Widget _buildNameColumn(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: widget.pack.name,
          child: Text(
            widget.pack.name,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionColumn(BuildContext context) {
    String description = widget.pack.description ?? ((widget.pack.isLocal) ? "Local content" : "No description");
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Tooltip(
          message: description,
          child: Text(
            description,
            style: TextStyle(fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildVersionColumn(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Version",
            style: TextStyle(fontSize: 11),
          ),
          Text(
            widget.pack.installedVersion ?? widget.pack.latestVersion ?? "N/A",
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildActionColumn(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(8),
      child: _buildActionWidget(context, pack: widget.pack),
    );
  }

  Widget _buildActionWidget(BuildContext context, {required Pack pack}) {
    if (pack.isUpdateAvailable) {
      return ActionButton(
        child: Text("Update"),
        showProgress: pack.isUpdating,
        progressText: "Updating",
        progress: widget.pack.updatingTask?.progress ?? 0,
        onPressed: () => repository.packs.updatePack(pack),
      );
    } else if (pack.isInstalled) {
      if (pack.isEnabled) {
        return ActionButton(
          child: Text("Remove"),
          showProgress: pack.isUninstalling,
          progressText: "Uninstalling",
          progress: widget.pack.uninstallingTask?.progress ?? 0,
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
        progress: widget.pack.installingTask?.progress ?? 0,
        onPressed: () => repository.packs.installPack(pack),
      );
    }
  }
}

enum ProfilePacksPackItemStyle {
  single,
  first,
  middle,
  last,
}
