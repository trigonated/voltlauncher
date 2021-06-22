import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/misc/show_in_file_explorer.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/VoltTextField.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/dialogs/alert_custom_dialog.dart';
import 'package:voltlauncher/ui/misc/exposed_popupmenu_button.dart';
import 'package:voltlauncher/ui/misc/installpicker.dart';
import 'package:voltlauncher/ui/misc/installpickerbutton.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';
import 'package:voltlauncher/ui/misc/sourcepicker.dart';
import 'package:voltlauncher/ui/misc/dialogs/add_revoltio_source_dialog.dart';
import 'package:voltlauncher/ui/misc/dialogs/add_source_dialog.dart';
import 'package:voltlauncher/ui/misc/dialogs/create_new_install_dialog.dart';
import 'package:voltlauncher/ui/settings/settings_page.dart';

/// Page that displays it's content organized into groups and rows.
abstract class GroupsPage extends StatefulWidget {}

abstract class GroupsPageState<T extends GroupsPage> extends State<T> {
  /// Used by SourcesManagement rows.
  ContentSource? _selectedSource;

  /// Used by SourcesManagement rows.
  late TextEditingController _sourceNameTextController;

  /// Used by InstallsManagement rows.
  String? _selectedInstall;

  @override
  void initState() {
    super.initState();

    _sourceNameTextController = TextEditingController(text: null);
    _sourceNameTextController.addListener(() => setState(() {}));
  }

  /// Refresh the content.
  ///
  /// Use [deselectSource] and [deselectInstall] to set [_selectedSource]
  /// and [_selectedInstall] to null, respectively.
  ///
  /// Subclasses can override this to actually refresh the content.
  void refresh({bool deselectSource = false, bool deselectInstall = false}) {
    setState(() {
      if (deselectSource) _selectedSource = null;
      if (deselectInstall) _selectedInstall = null;
    });
  }

  /// Show the dialog to add a Volt API source.
  void _showAddSourceDialog() {
    AddSourceDialog.show(
      context: context,
      addAction: (contentSource) {
        repository.sources.addSource(contentSource);
        setState(() {
          refresh();
        });
      },
    );
  }

  /// Show the dialog to add a Re-volt IO API source.
  void _showAddRevoltIOSourceDialog() {
    AddRevoltIOSourceDialog.show(
      context: context,
      addAction: (contentSource) {
        repository.sources.addSource(contentSource);
        setState(() {
          refresh();
        });
      },
    );
  }

  /// Called when the selected source is changed on
  /// SourcesManagement rows.
  void _onSelectedSourceChanged(ContentSource? selectedSource) {
    setState(() {
      this._selectedSource = selectedSource;
      this._sourceNameTextController.text = selectedSource?.name ?? "";
      this._selectedInstall = null;
    });
  }

  /// Called when the Save button on the source name field
  /// is pressed on SourcesManagement rows.
  void _saveSourceName() async {
    String newName = this._sourceNameTextController.text;
    if (newName.trim().isEmpty) return;
    await this._selectedSource?.rename(newName);
    setState(() {
      refresh();
    });
  }

  /// Called when the Delete button on the source name field
  /// is pressed on SourcesManagement rows.
  void _deleteSource() async {
    if (this._selectedSource == null) return;
    AlertCustomDialog.show(
      context: context,
      message: "Are you sure you want to delete \"${this._selectedSource!.name}\"?",
      actions: [
        AlertCustomDialogAction(
            text: "Yes",
            action: () async {
              // Delete the source
              await this._selectedSource!.delete();
              setState(() {
                refresh(deselectSource: true);
              });
            }),
        AlertCustomDialogAction(text: "No")
      ],
    );
  }

  /// Called when the Manage button on the source name field
  /// is pressed on SourcePicker rows.
  void _manageInstalledSources() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
  }

  /// Called when the selected install is changed on
  /// InstallsManagement rows.
  void _onSelectedInstallChanged(String? selectedInstall) {
    setState(() {
      this._selectedInstall = selectedInstall;
      this._selectedSource = null;
    });
  }

  /// Show the dialog to create a new install.
  void _showCreateNewInstallDialog() {
    CreateNewInstallDialog.show(
      context: context,
      onNewInstallCreated: (createdInstall) {
        setState(() {
          refresh();
        });
      },
    );
  }

  /// Opens the selected install's directory on the file explorer.
  void _openInstallDirectory() {
    if (this._selectedInstall == null) return;

    ShowInFileExplorer.showDirectoryInFileExplorer(LocalDirectories.appData.installs.install(this._selectedInstall!).directory);
  }

  /// Called when the Delete button on the source name field
  /// is pressed on InstallsManagement rows.
  void _deleteInstall() async {
    if (this._selectedInstall == null) return;
    AlertCustomDialog.show(
      context: context,
      message: "Are you sure you want to delete \"${this._selectedInstall!}\"?",
      actions: [
        AlertCustomDialogAction(
            text: "Yes",
            action: () async {
              // Delete the source
              await repository.local.deleteInstall(name: this._selectedInstall!);
              setState(() {
                refresh(deselectInstall: true);
              });
            }),
        AlertCustomDialogAction(text: "No")
      ],
    );
  }

  /// Build the groups that form the content of the page.
  ///
  /// Use the [buildGroup] and the various [build...Row] methods
  /// to build the content.
  List<Widget> buildGroups(BuildContext context);

  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main content on the left
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 0, 24),
            shrinkWrap: true,
            children: buildGroups(context),
          ),
        ),
        // Space on the right (similar to a [SidePanel])
        Padding(
          padding: EdgeInsets.all(24),
          child: SizedBox(width: 320),
        ),
      ],
    );
  }

  /// Build a group. This should be called inside [buildGroups].
  ///
  /// Use the various [build...Row] methods to build the [children].
  Widget buildGroup(BuildContext context, {required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildGroupHeader(context, title: title),
        _buildGroupContent(context, children: children),
      ],
    );
  }

  /// Build the header of a group.
  Widget _buildGroupHeader(BuildContext context, {required String title}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 16, 0, 2),
      child: Text(title),
    );
  }

  /// Build the content of a group.
  Widget _buildGroupContent(BuildContext context, {required List<Widget> children}) {
    return ItemContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  /// Build a row. The row contains a [title] on the left, and a [child] on the right.
  /// An optional [tooltip] can be provided as tooltip for the title.
  Widget buildGroupRow(BuildContext context, {required String title, String? tooltip, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // Title (on the left)
        Container(
          width: 200,
          child: (tooltip != null)
              ? Tooltip(
                  message: tooltip,
                  child: Text(title, textAlign: TextAlign.end),
                )
              : Text(title, textAlign: TextAlign.end),
        ),
        // Content (on the right)
        Expanded(child: child),
      ],
    );
  }

  /// Row with a TextField.
  ///
  /// Use [saveButtonVisible], [saveButtonText] and [onSaveButtonPressed]
  /// to provide a button on the right of the TextField (usually for saving).
  ///
  /// Use [extraButtonIcon], [extraButtonTooltip] and [onExtraButtonPressed]
  /// to provide an icon button on the right of the TextField
  Widget buildTextBoxGroupRow(
    BuildContext context, {
    required String title,
    String? hintText,
    required TextEditingController controller,
    required String saveButtonText,
    required bool saveButtonVisible,
    required VoidCallback? onSaveButtonPressed,
    IconData? extraButtonIcon,
    String? extraButtonTooltip,
    VoidCallback? onExtraButtonPressed,
  }) {
    return buildGroupRow(
      context,
      title: title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TextField
          Expanded(
            child: Container(
              padding: EdgeInsets.only(left: 16),
              height: 28,
              child: VoltTextField(
                controller: controller,
                hintText: hintText,
              ),
            ),
          ),
          // Save button
          SizedBox(width: (saveButtonVisible) ? 8 : 0),
          (saveButtonVisible)
              ? ElevatedButton(
                  child: Text(saveButtonText),
                  onPressed: onSaveButtonPressed,
                )
              : SizedBox.shrink(),
          // Extra button
          SizedBox(width: (extraButtonIcon != null) ? 8 : 0),
          (extraButtonIcon != null)
              ? Tooltip(
                  message: extraButtonTooltip!,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: const Size(36, 36)),
                    child: Icon(extraButtonIcon, size: 16, color: Colors.white),
                    onPressed: onExtraButtonPressed,
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  /// Row with a button.
  Widget buildButtonGroupRow(BuildContext context, {required String title, required String buttonText, required VoidCallback? onPressed}) {
    return buildGroupRow(
      context,
      title: title,
      child: Container(
        padding: EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
        child: ElevatedButton(
          child: Text(buttonText),
          onPressed: onPressed,
        ),
      ),
    );
  }

  /// Row with a list of one or more checkboxes.
  Widget buildCheckboxListGroupRow(BuildContext context, {required String title, required List<CheckboxListItem> items}) {
    return buildGroupRow(
      context,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items
            .map((e) => CheckboxListTile(
                  title: Text(e.title, style: TextStyle(fontSize: 14)),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  activeColor: Colors.orange,
                  value: e.state.value,
                  onChanged: (e.state.enabled != false) ? (value) => e.state.value = value ?? false : null,
                ))
            .toList(),
      ),
    );
  }

  /// Row with an image picker and a "Reset to default" button.
  Widget buildImagePickerGroupRow(
    BuildContext context, {
    required String title,
    required Image image,
    required VoidCallback onPickNewImage,
    required VoidCallback onResetToDefaultImage,
  }) {
    return buildGroupRow(
      context,
      title: title,
      child: Container(
        padding: EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image picker
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(36, 36)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: image,
              ),
              onPressed: onPickNewImage,
            ),
            // Reset to default button
            SizedBox(width: 8),
            ElevatedButton(
              child: Text("Reset to default"),
              onPressed: onResetToDefaultImage,
            ),
          ],
        ),
      ),
    );
  }

  /// Row with a source picker.
  ///
  /// [enabledSources] controls which sources appear checked (enabled).
  ///
  /// Use [showManageInstalledSourcesButton] to show a
  /// "Manage installed sources" button.
  Widget buildSourcePickerGroupRow(
    BuildContext context, {
    required String title,
    required Future<List<ContentSource>>? sources,
    required bool Function(ContentSource source) enabledSources,
    required void Function(ContentSource source, bool enabled) onSourceEnabledChanged,
    bool showManageInstalledSourcesButton = true,
  }) {
    // This is actually two rows, with the bottom one being titleless,
    // giving the appearance of a single row
    return Column(
      children: [
        // Source picker
        buildGroupRow(
          context,
          title: "Sources active on this profile:",
          child: SourcePicker.withCheckboxes(
            showPresetsSources: false,
            sourcesFuture: sources,
            enabledSources: enabledSources,
            onSourceEnabledChanged: onSourceEnabledChanged,
          ),
        ),
        // Buttons below the picker
        if (showManageInstalledSourcesButton) SizedBox(height: 8),
        if (showManageInstalledSourcesButton)
          buildGroupRow(
            context,
            title: "",
            child: Row(
              children: [
                Expanded(child: SizedBox.shrink()),
                ElevatedButton(
                  child: Text("Manage installed sources"),
                  onPressed: () => _manageInstalledSources(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Row that allows to manage a list of sources.
  Widget buildSourcesManagementGroupRow(
    BuildContext context, {
    required String title,
    required Future<List<ContentSource>> sources,
  }) {
    // This is actually three rows, but with the appearance of a single row
    return Column(
      children: [
        // Sources list
        buildGroupRow(
          context,
          title: title,
          child: SourcePicker.selectable(
            showPresetsSources: false,
            sourcesFuture: sources,
            selectedSource: this._selectedSource,
            onSelectedSourceChanged: (selectedSource) => _onSelectedSourceChanged(selectedSource),
          ),
        ),
        // Name textfield
        (this._selectedSource != null) ? SizedBox(height: 8) : SizedBox.shrink(),
        (this._selectedSource != null)
            ? buildTextBoxGroupRow(
                context,
                title: "Name:",
                hintText: "Source's name",
                controller: this._sourceNameTextController,
                saveButtonVisible:
                    ((this._sourceNameTextController.text != this._selectedSource!.name) && (this._sourceNameTextController.text.trim().isNotEmpty)),
                saveButtonText: "Save",
                onSaveButtonPressed: () => _saveSourceName(),
              )
            : SizedBox.shrink(),
        // Buttons on the bottom
        SizedBox(height: 8),
        buildGroupRow(
          context,
          title: "",
          child: Row(
            children: [
              // Add new source button
              SizedBox(width: 16),
              _buildAddNewSourceButton(context),
              // Space
              Expanded(child: SizedBox.shrink()),
              // Remove button
              ElevatedButton(
                child: Text("Remove"),
                onPressed: (this._selectedSource != null) ? () => _deleteSource() : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Row with an install picker.
  Widget buildInstallPickerGroupRow(
    BuildContext context, {
    required String title,
    required String? selectedInstall,
    required Function(String) onInstallSelected,
    required bool showNewInstallItem,
  }) {
    return buildGroupRow(
      context,
      title: title,
      child: Row(
        children: [
          // Install picker button
          SizedBox(width: 16),
          InstallPickerButton(
            selectedInstall: selectedInstall,
            onInstallSelected: onInstallSelected,
            showNewInstallItem: showNewInstallItem,
          ),
          // Opens installs folder button
          SizedBox(width: 8),
          ElevatedButton(
            child: Text("Open installs folder"),
            onPressed: () => ShowInFileExplorer.showDirectoryInFileExplorer(LocalDirectories.appData.installs.directory),
          ),
        ],
      ),
    );
  }

  /// Row that allows managing a list of installs.
  Widget buildInstallsManagementGroupRow(
    BuildContext context, {
    required String title,
    required Future<List<String>> installs,
  }) {
    // This is actually two rows, with the bottom one being titleless,
    // giving the appearance of a single row
    return Column(
      children: [
        // Install picker
        buildGroupRow(
          context,
          title: title,
          child: InstallPicker(
            installsFuture: installs,
            selectedInstall: this._selectedInstall,
            onSelectedInstallChanged: (selectedInstall) => _onSelectedInstallChanged(selectedInstall),
          ),
        ),
        // Buttons on the bottom
        SizedBox(height: 8),
        buildGroupRow(
          context,
          title: "",
          child: Row(
            children: [
              // New install button
              SizedBox(width: 16),
              ElevatedButton(
                child: Text("New install..."),
                onPressed: () => _showCreateNewInstallDialog(),
              ),
              // Space
              Expanded(child: SizedBox.shrink()),
              // Open folder button
              ElevatedButton(
                child: Text("Open folder"),
                onPressed: (this._selectedInstall != null) ? () => _openInstallDirectory() : null,
              ),
              // Remove button
              SizedBox(width: 8),
              ElevatedButton(
                child: Text("Remove"),
                onPressed: (this._selectedInstall != null) ? () => _deleteInstall() : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build a "Add new source" button.
  Widget _buildAddNewSourceButton(BuildContext context) {
    late ExposedPopupMenuButton popupMenuButton;
    List<ActionPopupMenuItem> menuItems = [
      ActionPopupMenuItem(
        child: Text("Volt Launcher source"),
        enabled: false,
        onSelected: () => _showAddSourceDialog(),
      ),
      ActionPopupMenuItem(
        child: Text("Re-Volt I/O based source"),
        onSelected: () => _showAddRevoltIOSourceDialog(),
      ),
    ];
    return popupMenuButton = ExposedPopupMenuButton<int>(
      child: ElevatedButton(
        child: Row(children: [
          SizedBox(width: 8),
          Text("Add source"),
          Icon(
            Icons.arrow_drop_down,
            color: Colors.white24,
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
  }
}

class CheckboxListItem {
  final String title;
  final CheckboxState state;

  CheckboxListItem({
    required this.title,
    required this.state,
  });
}

class CheckboxState {
  final State state;
  late bool _value;
  bool get value => this._value;
  set value(bool newValue) {
    // ignore: invalid_use_of_protected_member
    this.state.setState(() {
      this._value = newValue;
      onChanged(newValue);
    });
  }

  final bool? enabled;
  final ValueChanged<bool> onChanged;

  CheckboxState(
    this.state, {
    required bool initialValue,
    this.enabled,
    required this.onChanged,
  }) {
    this._value = initialValue;
  }
}
