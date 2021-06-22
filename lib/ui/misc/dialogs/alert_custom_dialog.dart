import 'package:flutter/material.dart';
import 'package:voltlauncher/ui/misc/dialogs/custom_dialog.dart';

/// A simple dialog with a title, message and actions.
class AlertCustomDialog extends CustomDialog {
  /// The main content of the dialog.
  final String message;

  /// The possible actions, shown as buttons. 
  /// If `null`, a default "OK" action is shown.
  final List<AlertCustomDialogAction>? actions;

  AlertCustomDialog({
    String? title,
    required this.message,
    this.actions,
  }) : super(
          title: title,
        );

  /// Show the dialog.
  static show({
    required BuildContext context,
    String? title,
    required String message,
    List<AlertCustomDialogAction>? actions,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertCustomDialog(
        title: title,
        message: message,
        actions: actions,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _AlertCustomDialogState();
}

class _AlertCustomDialogState extends CustomDialogState<AlertCustomDialog> {
  @override
  Widget buildContent(BuildContext context) {
    return Text(widget.message);
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return (widget.actions ?? [AlertCustomDialogAction(text: "OK", action: null)])
        .map((e) => TextButton(
            child: new Text(e.text),
            onPressed: () {
              Navigator.of(context).pop();
              e.action?.call();
            }))
        .toList();
  }
}

/// An action for the dialog.
class AlertCustomDialogAction {
  final String text;
  final VoidCallback? action;

  AlertCustomDialogAction({
    required this.text,
    this.action,
  });
}
