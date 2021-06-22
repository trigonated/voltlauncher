import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/model/objects/profiles/appprofile.dart';

/// Widget that displays the icon of a profile.
/// Either the [profile] or the [profileId] parameter must be provided.
class ProfileIcon extends StatefulWidget {
  final AppProfile? profile;
  final String? profileId;
  final double size;

  ProfileIcon({
    this.profile,
    this.profileId,
    required this.size,
  }) : super() {
    if ((this.profile == null) && (this.profileId == null)) {
      throw Exception("Either a profile or profileId parameter must be provided");
    }
  }

  @override
  State<StatefulWidget> createState() => _ProfileIconState();
}

class _ProfileIconState extends State<ProfileIcon> {
  late Future<AppProfile?> profile;

  @override
  void initState() {
    super.initState();

    if (widget.profile != null) {
      profile = Future.value(widget.profile);
    } else if (widget.profileId != null) {
      profile = repository.profiles.fetchProfile(id: widget.profileId);
    } else {
      profile = Future.error(Exception("Either a profile or profileId parameter must be provided"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppProfile?>(
      future: profile,
      builder: (context, snapshot) {
        // Check if the profile is loaded and contains an icon
        bool hasIcon = (snapshot.data?.iconFile.existsSync() == true);
        return Image(
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          image: ((hasIcon)
                  ? FileImage(snapshot.data!.iconFile) // The profile has an icon
                  : AssetImage(Assets.graphics.profile_default) // Profile is not loaded/doesn't have an icon
              ) as ImageProvider,
        );
      },
    );
  }
}
