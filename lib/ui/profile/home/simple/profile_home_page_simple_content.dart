import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/ui/misc/versiontext.dart';
import 'package:voltlauncher/ui/profile/home/profile_home_page_content.dart';

/// Simple home page content.
class ProfileHomePageSimpleContent extends StatefulWidget {
  @override
  _ProfileHomePageSimpleContentState createState() => _ProfileHomePageSimpleContentState();
}

class _ProfileHomePageSimpleContentState extends ProfileHomePageContentState<ProfileHomePageSimpleContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Volt launcher logo
          Image.asset(
            Assets.graphics.logo,
            width: 128,
            height: 128,
          ),
          // Volt launcher name
          Text("Volt Launcher", style: TextStyle(fontSize: 30)),
          VersionText(style: const TextStyle(color: Colors.white24)),
          // Play button
          SizedBox(height: 64),
          _buildPlayButton(context),
          // Progress bar/Update all button
          SizedBox(height: 16),
          FractionallySizedBox(
            widthFactor: 0.3,
            child: _buildProgressBar(context),
          ),
        ],
      ),
    );
  }

  /// Build the "Play" button.
  Widget _buildPlayButton(BuildContext context) {
    return SizedBox(
      width: 192,
      height: 64,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.orange, onPrimary: Colors.black),
        child: Text("PLAY", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        onPressed: (this.longTasksProgress == null) ? () => play() : null,
      ),
    );
  }

  /// Build a long tasks progress bar/"Update" button/"No updates available" text widget.
  Widget _buildProgressBar(BuildContext context) {
    if (this.longTasksProgress != null) {
      // Tasks running
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Text("Installing... (${(this.longTasksProgress! * 100.0).floor()}%)"),
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: this.longTasksProgress,
          ),
        ],
      );
    } else {
      // No tasks running
      return Center(
        child: FutureBuilder<bool>(
          future: this.areUpdatesAvailable,
          builder: (context, snapshot) {
            if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
              // Loaded
              if (snapshot.data!) {
                // Updates available
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text("Updates available", style: const TextStyle(color: Colors.white)),
                    SizedBox(width: 16),
                    ElevatedButton(child: Text("Update all"), onPressed: () => updateAll()),
                  ],
                );
              } else {
                // No updates available
                return Text("Up-to-date. Ready to play", style: const TextStyle(color: Colors.white24));
              }
            } else if (snapshot.hasError) {
              // Error
              return Text("Couldn't check for updates", style: const TextStyle(color: Colors.white24));
            } else {
              // Loading
              return Text("Checking for updates", style: const TextStyle(color: Colors.white24));
            }
          },
        ),
      );
    }
  }
}
