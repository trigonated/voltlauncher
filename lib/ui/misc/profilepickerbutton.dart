import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';
import 'package:voltlauncher/ui/misc/exposed_popupmenu_button.dart';
import 'package:voltlauncher/ui/misc/profileicon.dart';
import 'package:voltlauncher/ui/newprofile/newprofile_page.dart';
import 'package:voltlauncher/ui/settings/settings_page.dart';

/// Button that allows to change the current profile.
class ProfilePickerButton extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfilePickerButtonState();
}

class _ProfilePickerButtonState extends State<ProfilePickerButton> {
  late Future<List<AppProfile>> profiles;
  AppProfile? get currentProfile => repository.currentProfile;

  @override
  void initState() {
    super.initState();

    profiles = repository.profiles.fetchProfiles();
  }

  @override
  Widget build(BuildContext context) {
    late ExposedPopupMenuButton popupMenuButton;
    return FutureBuilder<List<AppProfile>>(
      future: profiles,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Data loaded
          return popupMenuButton = ExposedPopupMenuButton<int>(
            child: TextButton(
              style: TextButton.styleFrom(
                primary: Colors.white,
                textStyle: TextStyle(fontSize: 14),
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              ),
              child: _buildButtonContent(context),
              onPressed: () {
                if (this.currentProfile != null) {
                  popupMenuButton.showButtonMenu();
                } else {}
              },
            ),
            itemBuilder: (context) => ((snapshot.hasData) ? snapshot.data! : [])
                // Normal items (profiles)
                .map((e) => PopupMenuItem(
                      value: snapshot.data!.indexOf(e),
                      child: _buildItemPopupMenuItem(context, e),
                    ))
                .followedBy([
              // Create new profile item
              PopupMenuItem(
                value: -1,
                child: _buildAddPopupMenuItem(context),
              ),
              // Settings item
              PopupMenuItem(
                value: -2,
                child: _buildSettingsPopupMenuItem(context),
              )
            ]).toList(),
            onSelected: (value) {
              if (value == -1) {
                // Create new profile item selected
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NewProfilePage()),
                );
              } else if (value == -2) {
                // Settings item selected
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              } else {
                // Normal item selected

                // Change both the current profile and the default profile setting
                repository.currentProfile = snapshot.data![value];
                repository.appSettings.defaultProfile = snapshot.data![value].id;
              }
            },
          );
        } else {
          // Loading
          return CircularProgressIndicator();
        }
      },
    );
  }

  /// Create the content of the popup button. This is either
  /// a normal profile item or a Create New Profile item.
  Widget _buildButtonContent(BuildContext context) {
    return Row(
      children: [
        (this.currentProfile != null)
            ? _buildItemPopupMenuItem(context, this.currentProfile!) // Show the current profile
            : _buildAddPopupMenuItem(context) // Show the Create new profile item
        ,
        Icon(
          Icons.arrow_drop_down,
          color: Colors.white,
          size: 16,
        ),
      ],
    );
  }

  /// Build a normal item (profile).
  Widget _buildItemPopupMenuItem(BuildContext context, AppProfile item) {
    return Row(
      children: [
        ProfileIcon(profile: item, size: 24),
        Container(width: 8),
        Text(item.name),
        Container(width: 8),
      ],
    );
  }

  /// Build a Create new profile item.
  Widget _buildAddPopupMenuItem(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.add, size: 24),
        Container(width: 8),
        Text("Create new profile"),
        Container(width: 8),
      ],
    );
  }

  /// Build a Settings item.
  Widget _buildSettingsPopupMenuItem(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.settings, size: 24),
        Container(width: 8),
        Text("Settings"),
        Container(width: 8),
      ],
    );
  }
}
