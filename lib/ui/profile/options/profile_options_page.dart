import 'dart:io';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/groups_page.dart';
import 'package:voltlauncher/misc/file_picker.dart';
import 'package:voltlauncher/misc/url_opener.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/dialogs/alert_custom_dialog.dart';

class ProfileOptionsPage extends GroupsPage {
  @override
  _ProfileOptionsPageState createState() => _ProfileOptionsPageState();
}

class _ProfileOptionsPageState extends GroupsPageState<ProfileOptionsPage> {
  AppProfile get profile => repository.currentProfile!;
  late Future<List<ContentSource>> _sources;
  late TextEditingController _profileNameTextController;
  late TextEditingController _extraParametersTextController;

  @override
  void initState() {
    super.initState();

    _sources = repository.sources.fetchSources(expanded: true);

    _profileNameTextController = TextEditingController(text: profile.name);
    _profileNameTextController.addListener(() => setState(() {}));

    _extraParametersTextController = TextEditingController(text: profile.launchParameters.additionalParameters);
    _extraParametersTextController.addListener(() => setState(() {}));
  }

  void _saveProfileName() async {
    String newName = _profileNameTextController.text;
    if (newName.isEmpty) return;
    await this.profile.changeName(newName);
    setState(() {});
  }

  void _pickProfileImage() async {
    File? file = await FilePicker.showImagePicker();
    if (file != null) {
      await this.profile.changeIcon(file);
      setState(() {});
    }
  }

  void _resetProfileImage() async {
    await this.profile.resetIcon();
    setState(() {});
  }

  void _changeInstall(String install) async {
    await this.profile.changeInstall(install);
    setState(() {});
  }

  void _onSourceEnabledChanged(ContentSource source, bool enabled) {
    setState(() {
      if (enabled) {
        this.profile.enableSource(source);
      } else {
        this.profile.disableSource(source);
      }
    });
  }

  void _changeFlagLaunchParameter(String name, bool value) async {
    this.profile.launchParameters.setFlagParameter(name, value);
    await this.profile.saveLaunchParameters();
    setState(() {});
  }

  void _saveAdditionalParameters() async {
    this.profile.launchParameters.additionalParameters = _extraParametersTextController.text;
    await this.profile.saveLaunchParameters();
    setState(() {});
  }

  void _clearCache() async {
    repository.clearCache();
  }

  void _deleteProfile() async {
    AlertCustomDialog.show(context: context, message: "Are you sure you want to delete this profile?", actions: [
      AlertCustomDialogAction(
        text: "Yes",
        action: () {
          repository.profiles.deleteProfile(this.profile);
        },
      ),
      AlertCustomDialogAction(text: "No"),
    ]);
  }

  @override
  List<Widget> buildGroups(BuildContext context) {
    return [
      _buildProfileGroup(context),
      _buildContentsGroup(context),
      _buildLaunchParametersGroup(context),
      _buildManagementGroup(context),
    ];
  }

  Widget _buildProfileGroup(BuildContext context) {
    return buildGroup(
      context,
      title: "Profile",
      children: [
        buildTextBoxGroupRow(
          context,
          title: "Profile name:",
          hintText: "Re-Volt",
          controller: this._profileNameTextController,
          saveButtonVisible: (this._profileNameTextController.text != this.profile.name),
          saveButtonText: "Save",
          onSaveButtonPressed: () => _saveProfileName(),
        ),
        SizedBox(height: 8),
        buildImagePickerGroupRow(
          context,
          title: "Icon:",
          image: Image.file(this.profile.iconFile, width: 64, height: 64, fit: BoxFit.contain),
          onPickNewImage: () => _pickProfileImage(),
          onResetToDefaultImage: () => _resetProfileImage(),
        ),
      ],
    );
  }

  Widget _buildContentsGroup(BuildContext context) {
    return buildGroup(
      context,
      title: "Contents",
      children: [
        buildInstallPickerGroupRow(
          context,
          title: "Install:",
          selectedInstall: this.profile.install,
          onInstallSelected: (install) => _changeInstall(install),
          showNewInstallItem: true,
        ),
        SizedBox(height: 8),
        buildSourcePickerGroupRow(
          context,
          title: "Sources active on this profile:",
          sources: this._sources,
          enabledSources: (source) => this.profile.isSourceEnabled(source),
          onSourceEnabledChanged: (source, enabled) => _onSourceEnabledChanged(source, enabled),
        ),
      ],
    );
  }

  Widget _buildLaunchParametersGroup(BuildContext context) {
    return buildGroup(
      context,
      title: "Launch parameters",
      children: [
        buildCheckboxListGroupRow(
          context,
          title: "Game:",
          items: [
            _flagParameterCheckboxListItem(parameter: "gamegauge", title: "Launch the game in benchmark mode"),
            _flagParameterCheckboxListItem(parameter: "gogodemo", title: "Launch the game in demo mode"),
            _flagParameterCheckboxListItem(parameter: "nodemo", title: "Disable the demo screensaver"),
            _flagParameterCheckboxListItem(parameter: "nointro", title: "Disable the intro"),
            _flagParameterCheckboxListItem(parameter: "window", title: "Windowed mode"),
            _flagParameterCheckboxListItem(parameter: "nopause", title: "Don't pause the game when the window is unfocused"),
            _flagParameterCheckboxListItem(parameter: "nosound", title: "Disable sound"),
            _flagParameterCheckboxListItem(parameter: "savereplays", title: "Save replays"),
            _flagParameterCheckboxListItem(parameter: "sload", title: "Disable loading screens"),
          ],
        ),
        SizedBox(height: 8),
        buildCheckboxListGroupRow(
          context,
          title: "Multiplayer:",
          items: [
            _flagParameterCheckboxListItem(parameter: "hidechat", title: "Hide in-game chat messages"),
            _flagParameterCheckboxListItem(parameter: "sessionlog", title: "Save the session's log"),
            _flagParameterCheckboxListItem(parameter: "autokick", title: "Auto-kick players using modified cars"),
            _flagParameterCheckboxListItem(parameter: "nolatejoin", title: "Block new players from spectating an ongoing race"),
          ],
        ),
        SizedBox(height: 8),
        buildTextBoxGroupRow(
          context,
          title: "Extra parameters:",
          hintText: null,
          controller: this._extraParametersTextController,
          saveButtonVisible: (this._extraParametersTextController.text != this.profile.launchParameters.additionalParameters),
          saveButtonText: "Save",
          onSaveButtonPressed: () => _saveAdditionalParameters(),
          extraButtonIcon: Icons.help_outline,
          extraButtonTooltip: "Open RVGL documentation",
          onExtraButtonPressed: () => UrlOpener.openUrl("https://yethiel.gitlab.io/RVDocs/#launch-parameters"),
        ),
      ],
    );
  }

  Widget _buildManagementGroup(BuildContext context) {
    return buildGroup(
      context,
      title: "Management",
      children: [
        buildButtonGroupRow(
          context,
          title: "Cache:",
          buttonText: "Clear cache",
          onPressed: () => _clearCache(),
        ),
        SizedBox(height: 8),
        buildButtonGroupRow(
          context,
          title: "Delete profile:",
          buttonText: "Delete profile",
          onPressed: () => _deleteProfile(),
        ),
      ],
    );
  }

  CheckboxListItem _flagParameterCheckboxListItem({required String parameter, required String title}) {
    final CheckboxState state = CheckboxState(
      this,
      initialValue: this.profile.launchParameters.getFlagParameter(parameter),
      onChanged: (value) => _changeFlagLaunchParameter(parameter, value),
    );
    return CheckboxListItem(
      title: title,
      state: state,
    );
  }
}
