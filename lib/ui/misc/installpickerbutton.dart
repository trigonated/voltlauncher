import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/exposed_popupmenu_button.dart';
import 'package:voltlauncher/ui/misc/dialogs/create_new_install_dialog.dart';

/// Button that allows to pick an install.
///
/// If [showNewInstallItem] is `true`, an extra option to
/// create a new install is shown.
class InstallPickerButton extends StatefulWidget {
  final String? selectedInstall;
  final void Function(String install) onInstallSelected;
  final bool showNewInstallItem;

  InstallPickerButton({
    required this.selectedInstall,
    required this.onInstallSelected,
    required this.showNewInstallItem,
  });

  @override
  State<StatefulWidget> createState() => _InstallPickerButtonState();
}

class _InstallPickerButtonState extends State<InstallPickerButton> {
  /// The list of installs.
  late Future<List<String>> _installs;

  @override
  void initState() {
    super.initState();
    _installs = repository.local.fetchInstalls();
  }

  /// Refresh the data.
  void _refresh() {
    _installs = repository.local.fetchInstalls();
  }

  /// Called when the New Install item is selected.
  void _onNewInstallSelected() {
    CreateNewInstallDialog.show(
      context: context,
      onNewInstallCreated: (createdInstall) {
        setState(() {
          _refresh();
          widget.onInstallSelected(createdInstall);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _installs,
      builder: (context, snapshot) {
        if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
          // Data is loaded

          late ExposedPopupMenuButton popupMenuButton;
          // Create the list of menu items
          List<ActionPopupMenuItem> menuItems = snapshot.data!
              .map((e) => ActionPopupMenuItem(
                    child: Text(e),
                    onSelected: () => widget.onInstallSelected(e),
                  ))
              .toList();
          // Add an additional New Install button
          if (widget.showNewInstallItem) {
            menuItems.add(ActionPopupMenuItem(
              child: Text("New install..."),
              onSelected: () => _onNewInstallSelected(),
            ));
          }
          return popupMenuButton = ExposedPopupMenuButton<int>(
            child: ElevatedButton(
              child: Row(children: [
                SizedBox(width: 8),
                Text(widget.selectedInstall ?? snapshot.data!.firstOrNull ?? "No installs"),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white,
                  size: 16,
                ),
              ]),
              onPressed: () {
                popupMenuButton.showButtonMenu();
              },
            ),
            itemBuilder: (context) => menuItems,
            onSelected: (value) {
              menuItems.firstWhere((e) => e.value == value).onSelected?.call();
            },
          );
        } else if (snapshot.hasError) {
          // Error
          return Text("${snapshot.error}");
        } else {
          // Loading
          return OutlinedButton(
            child: CircularProgressIndicator(),
            onPressed: null,
          );
        }
      },
    );
  }
}
