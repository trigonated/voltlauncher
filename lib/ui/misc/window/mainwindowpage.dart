import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/ui/misc/window/window_titlebar.dart';
import 'package:window_control/window_control.dart';

/// The base page. Contains a bar at the top that can be used
/// as the window titlebar (if [AppSettings.useCustomWindowFrame] is enabled).
abstract class MainWindowPage extends StatefulWidget {}

abstract class MainWindowPageState extends State<MainWindowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          // Window border (when custom window frame is on)
          foregroundDecoration: ((appSettings.useCustomWindowFrame) && (WindowControl.isSupported))
              ? BoxDecoration(
                  border: Border.all(color: Colors.white12, width: 1),
                )
              : null,
          child: Stack(
            children: [
              // Background
              _buildBackground(context),
              // Foreground
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Titlebar
                  WindowTitleBar(
                    windowControlsEnabled: ((appSettings.useCustomWindowFrame) && (WindowControl.isSupported)),
                    child: buildWindowTitleContent(context),
                  ),
                  // Main content
                  Expanded(child: buildContent(context)),
                ],
              ),
            ],
          )),
    );
  }

  /// Build the background.
  Widget _buildBackground(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      alignment: Alignment.topRight,
      child: Image(image: AssetImage(Assets.graphics.background_default)),
    );
  }

  /// Build the content of the window title (top bar when custom window frame is off).
  ///
  /// Use [buildSimpleWindowTitleContent] to build a simple title with just
  /// a text (most common use case).
  Widget buildWindowTitleContent(BuildContext context);

  /// Build the main content.
  Widget buildContent(BuildContext context);

  /// Build a window title consisting of a simple title text. This is the most
  /// common use case for a window title.
  Widget buildSimpleWindowTitleContent(BuildContext context, String title) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(title.toUpperCase(), style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}
