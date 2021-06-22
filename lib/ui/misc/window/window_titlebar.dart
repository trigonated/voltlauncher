import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/ui/misc/window/titlebar_backbutton.dart';
import 'package:voltlauncher/ui/misc/window/titlebar_button.dart';
import 'package:voltlauncher/ui/misc/window/titlebar_caption.dart';
import 'package:window_control/window_control.dart';

/// Widget that works as a custom window titlebar, or simply as a top bar,
/// depending on the "use custom title bar" setting.
class WindowTitleBar extends StatelessWidget {
  /// The "title" content of the title bar.
  final Widget child;

  /// Whether the custom titlebar widgets (min, max, close, etc) are shown.
  final bool windowControlsEnabled;

  WindowTitleBar({
    required this.child,
    this.windowControlsEnabled = true,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: Colors.grey[800]!.withAlpha(63),
      // decoration:
      //     BoxDecoration(color: Colors.white12, boxShadow: [BoxShadow(color: Colors.black38, offset: const Offset(0, 5), blurRadius: 10.0, spreadRadius: 2.0)]),
      // foregroundDecoration: BoxDecoration(
      //   border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
      // ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back button
              (Navigator.canPop(context)) ? _buildBackButton(context) : SizedBox.shrink(),
              // Title
              this.child,
              // Caption (draggable part)
              Expanded(
                child: (this.windowControlsEnabled) ? TitleBarCaption() : SizedBox.shrink(),
              ),
              // Buttons
              (this.windowControlsEnabled) ? _buildMinimizeButton(context) : SizedBox.shrink(),
              (this.windowControlsEnabled) ? _buildMaximizeButton(context) : SizedBox.shrink(),
              (this.windowControlsEnabled) ? _buildCloseButton(context) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the back button.
  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: TitleBarBackButton(
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Build the minimize button.
  Widget _buildMinimizeButton(BuildContext context) {
    return TitleBarButton(
      icon: Icons.remove_sharp,
      onPressed: () => WindowControl.minimizeWindow(),
    );
  }

  /// Build the maximize button.
  Widget _buildMaximizeButton(BuildContext context) {
    return TitleBarButton(
      icon: Icons.crop_square_sharp,
      onPressed: () => WindowControl.windowTitleDoubleTap(),
    );
  }

  /// Build the close button.
  Widget _buildCloseButton(BuildContext context) {
    return TitleBarButton(
      isCloseButton: true,
      icon: Icons.close_sharp,
      onPressed: () => WindowControl.closeWindow(),
    );
  }
}
