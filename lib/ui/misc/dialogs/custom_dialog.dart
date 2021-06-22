import 'package:flutter/material.dart';

/// Base class for creating dialogs.
abstract class CustomDialog extends StatefulWidget {
  /// The title of the dialog.
  final String? title;

  CustomDialog({
    required this.title,
  }) : super();

  // @override
  // State<StatefulWidget> createState() => CustomDialogState();
}

abstract class CustomDialogState<T extends CustomDialog> extends State<T> {
  /// Whether the dialog is loading. When loading, a progress indicator
  /// may be shown instead of the normal dialog content.
  late bool isLoading;

  @override
  void initState() {
    super.initState();
    this.isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    // Build the title
    Widget? titleWidget = (widget.title != null) ? buildTitle(context, widget.title!) : null;

    // Build the content
    Widget contentWidget = buildContent(context);

    // Build the actions (buttons at the bottom of the dialog)
    Widget? actionsWidget;
    List<Widget>? actions = buildActions(context);
    if (actions != null) {
      actionsWidget = ButtonBar(
        children: actions,
      );
    }

    // Create the dialog
    return Dialog(
      // backgroundColor: Theme.of(context).dialogBackgroundColor.withAlpha(64),
      elevation: 24,
      // insetPadding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      // clipBehavior: Clip.none,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4.0))),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Title
            if (titleWidget != null) Padding(padding: EdgeInsets.all(16), child: titleWidget),
            // Loading
            if (this.isLoading) Padding(padding: EdgeInsets.all(16), child: buildLoadingContent(context)),
            // Content
            if (!this.isLoading) Padding(padding: EdgeInsets.all(16), child: contentWidget),
            // Actions
            if ((!this.isLoading) && (actionsWidget != null)) actionsWidget,
          ],
        ),
      ),
    );
  }

  /// Build the title of the dialog.
  Widget buildTitle(BuildContext context, String title) {
    return Text(title, style: TextStyle(fontSize: 20));
  }

  /// Build the main content of the dialog.
  Widget buildContent(BuildContext context);

  /// Build the actions (ok, cancel, etc) shown at the bottom of the dialog.
  List<Widget>? buildActions(BuildContext context);

  /// Build the loading ui shown when [loading] is `true`.
  Widget buildLoadingContent(BuildContext context) {
    return Center(child: CircularProgressIndicator());
  }
}
