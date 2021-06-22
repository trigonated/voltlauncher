import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/exposed_popupmenu_button.dart';

/// Special button (either normal or dropdown) that can turn into a progress bar.
///
/// Useful for things like "Install" buttons that turn into a progress bar to
/// show the installation progress.
class ActionButton extends StatelessWidget {
  /// The content of the button. Usually a [Text].
  final Widget child;

  /// Whether to show a progress bar instead of the button.
  final bool showProgress;

  /// An accompanying text for the progress bar (e.g. "Installing...").
  final String? progressText;

  /// The progress of the progress bar.
  final double progress;

  /// If non-null, the button acts as a popup menu button.
  final List<ActionPopupMenuItem>? popupMenuItems;

  /// Callback for when the button is pressed.
  final VoidCallback? onPressed;

  ActionButton({
    required this.child,
    this.showProgress = false,
    this.progressText,
    this.progress = 0,
    this.popupMenuItems,
    this.onPressed,
  }) : super();

  @override
  Widget build(BuildContext context) {
    if (this.showProgress) {
      return _buildProgress(context);
    } else if (popupMenuItems != null) {
      return _buildPopupMenuButton(context);
    } else {
      return _buildButton(context);
    }
  }

  /// Build the "normal" button.
  Widget _buildButton(BuildContext context) {
    return ElevatedButton(
      child: this.child,
      onPressed: this.onPressed,
    );
  }

  /// Build the popup menu button.
  Widget _buildPopupMenuButton(BuildContext context) {
    late ExposedPopupMenuButton popupMenuButton;
    return popupMenuButton = ExposedPopupMenuButton<int>(
      child: ElevatedButton(
        child: this.child,
        onPressed: () {
          popupMenuButton.showButtonMenu();
        },
      ),
      itemBuilder: (context) => this.popupMenuItems ?? List<PopupMenuEntry<int>>.empty(),
      onSelected: (value) {
        this.popupMenuItems!.firstWhere((e) => e.value == value).onSelected?.call();
      },
    );
  }

  /// Build the progress bar with an accompanying text.
  Widget _buildProgress(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          this.progressText ?? "",
          style: TextStyle(fontSize: 11),
        ),
        LinearProgressIndicator(
          value: this.progress,
        ),
      ],
    );
  }
}
