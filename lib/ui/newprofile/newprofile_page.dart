import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/profiles/profilepreset.dart';
import 'package:voltlauncher/ui/misc/VoltTextField.dart';
import 'package:voltlauncher/ui/misc/installpickerbutton.dart';
import 'package:voltlauncher/ui/misc/window/mainwindowpage.dart';
import 'package:voltlauncher/ui/newprofile/newprofile_presets_item.dart';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/ui/profile/profile_page.dart';

/// Page for creating a new profile.
///
/// [showOptions] controls whether the bar at the bottom is shown or not.
class NewProfilePage extends MainWindowPage {
  /// Whether the bar at the bottom is shown or not.
  final bool showOptions;

  NewProfilePage({
    this.showOptions = true,
  }) : super();

  @override
  _NewProfilePageState createState() => _NewProfilePageState();
}

class _NewProfilePageState extends MainWindowPageState with SingleTickerProviderStateMixin {
  /// The list of presets.
  late Future<List<ProfilePreset>> _presets;

  /// The selected preset.
  ProfilePreset? _selectedPreset;

  /// See [_profileName].
  late TextEditingController _profileNameTextController;

  /// The name of the new profile.
  String get _profileName => this._profileNameTextController.text.trim();

  /// The selected install.
  String? _selectedInstall;

  /// Whether the Create Profile button can be clicked or not.
  bool get canCreateProfile => ((this._selectedPreset != null) && (this._profileName.isNotEmpty) && (this._selectedInstall != null));

  @override
  void initState() {
    super.initState();

    // Fetch the list of presets
    this._presets = repository.profiles.fetchPresets();
    // Initialise the profile name textfield
    this._profileNameTextController = TextEditingController(text: ((widget as NewProfilePage).showOptions) ? "" : "Re-Volt");
    this._profileNameTextController.addListener(() => setState(() {}));
    // Set the initial selected install to the first install (or "default")
    this._selectedInstall = ((widget as NewProfilePage).showOptions) ? repository.local.fetchInstallsSync().firstOrNull : "default";
  }

  /// Called when a different install is selected.
  void _onInstallSelected(String? install) {
    setState(() {
      this._selectedInstall = install;
    });
  }

  /// Create the new profile.
  void _createProfile() async {
    // Create the profile
    await repository.profiles.createProfile(
      preset: this._selectedPreset!,
      name: this._profileName,
      install: this._selectedInstall!,
      setAsCurrent: true,
    );
    // Navigate to the profile page (and clearing the backstack)
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ProfilePage()), (route) => false);
  }

  Widget buildWindowTitleContent(BuildContext context) => buildSimpleWindowTitleContent(context, "Create new profile");

  Widget buildContent(BuildContext context) {
    return Column(
      children: [
        // Content
        Expanded(
          child: FutureBuilder<List<ProfilePreset>>(
            future: this._presets,
            builder: (context, snapshot) {
              if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
                // Data loaded

                return ListView.builder(
                  padding: const EdgeInsets.all(24),
                  shrinkWrap: true,
                  itemCount: (snapshot.data?.length ?? 0) + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      // First item is the header
                      return _buildContentListHeader(context);
                    } else {
                      // Other items are the list items
                      return _buildContentListItem(context, item: snapshot.data![index - 1]);
                    }
                  },
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
        ),
        // Bottom bar
        _buildBottomBar(context),
      ],
    );
  }

  /// Build the header of the list.
  Widget _buildContentListHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(128, 0, 128, 12),
      child: Text("Select a preset to choose what content to install:"),
    );
  }

  /// Build the normal list items.
  Widget _buildContentListItem(BuildContext context, {required ProfilePreset item}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 128, vertical: 12),
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Radio button
          Radio<ProfilePreset>(
            value: item,
            groupValue: this._selectedPreset,
            activeColor: Colors.orange,
            onChanged: (ProfilePreset? value) {
              setState(() {
                this._selectedPreset = value;
              });
            },
          ),
          // Preset item
          SizedBox(width: 8),
          Expanded(
            child: NewProfilePresetsItem(
              preset: item,
              onTap: (e) => setState(() {
                this._selectedPreset = e;
              }),
              onOptionalContentCheckedChanged: (e, v) => setState(() {
                this._selectedPreset = e;
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the bottom bar, a bar with some fields and options for the new profile.
  Widget _buildBottomBar(BuildContext context) {
    return Container(
      foregroundDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white24, width: 1)),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: _buildOptions(context).followedBy([
          Expanded(child: SizedBox.shrink()),
          ElevatedButton(
            child: Text("Create profile"),
            onPressed: (this.canCreateProfile) ? () => _createProfile() : null,
          ),
        ]).toList(),
      ),
    );
  }

  /// Build the options for the bottom bar.
  ///
  /// If [showOptions] is false, an empty list is returned.
  List<Widget> _buildOptions(BuildContext context) {
    if (!(widget as NewProfilePage).showOptions) return [];

    return [
      // Profile name
      Text("Profile name:"),
      SizedBox(width: 16),
      SizedBox(
        width: 200,
        height: 28,
        child: VoltTextField(
          controller: this._profileNameTextController,
          hintText: "Profile name",
        ),
      ),
      // Install
      SizedBox(width: 32),
      Text("Install:"),
      SizedBox(width: 16),
      InstallPickerButton(
        selectedInstall: this._selectedInstall,
        onInstallSelected: (install) => _onInstallSelected(install),
        showNewInstallItem: true,
      ),
    ];
  }
}
