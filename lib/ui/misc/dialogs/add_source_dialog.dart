import 'package:flutter/material.dart';
import 'package:voltlauncher/model/misc/contentsource_getter.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/VoltTextField.dart';
import 'package:voltlauncher/ui/misc/dialogs/alert_custom_dialog.dart';
import 'package:voltlauncher/ui/misc/dialogs/custom_dialog.dart';

/// Dialog that prompts the user to add a source based on the Volt Launcher APIs.
///
/// This only obtains the source data, you still need to call [repository.sources.addSource]
/// to actually add the source.
class AddSourceDialog extends CustomDialog {
  /// The primary action.
  final void Function(ContentSource contentSource) addAction;

  AddSourceDialog({
    required this.addAction,
  }) : super(
          title: "Add source",
        );

  /// Show the dialog
  static show({
    required BuildContext context,
    required void Function(ContentSource contentSource) addAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AddSourceDialog(addAction: addAction),
    );
  }

  @override
  State<StatefulWidget> createState() => _AddSourceDialogState();
}

class _AddSourceDialogState extends CustomDialogState<AddSourceDialog> {
  /// See [_sourceUrl].
  late TextEditingController _sourceUrlTextController;

  /// The url field.
  String get _sourceUrl => _sourceUrlTextController.text;

  /// Whether the add action can be clicked.
  bool get _canAdd => (this._sourceUrl.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();

    // Initialize the textfield controllers
    _sourceUrlTextController = TextEditingController(text: null);
    _sourceUrlTextController.addListener(() => setState(() {}));
  }

  /// Called when the add action is clicked.
  void _onAddActionClick() async {
    setState(() {
      this.isLoading = true;
    });
    // Try to create the source.
    ContentSource? contentSource = await ContentSourceGetter.getContentSource(
      url: this._sourceUrl,
    );
    if (contentSource != null) {
      // Source was created successfully.
      // Close the dialog and call the callback.
      Navigator.of(context).pop();
      widget.addAction(contentSource);
    } else {
      // Couldn't create the source.
      setState(() {
        this.isLoading = false;
      });
      AlertCustomDialog.show(context: context, message: "Error loading the source");
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(context, label: "URL:", child: _buildTextField(context, hintText: "Url", textFieldController: this._sourceUrlTextController)),
      ],
    );
  }

  /// Build a row consisting of a [label] text and a [child] field.
  Widget _buildRow(BuildContext context, {required String label, required Widget child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Container(
          width: 64,
          child: Text(label, textAlign: TextAlign.end),
        ),
        // Field
        SizedBox(width: 16),
        child,
      ],
    );
  }

  /// Build a textfield field.
  Widget _buildTextField(BuildContext context, {required String? hintText, required TextEditingController textFieldController}) {
    return Container(
      width: 240,
      height: 28,
      child: VoltTextField(
        controller: textFieldController,
        hintText: hintText,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      // Add
      TextButton(
        child: new Text("Add"),
        onPressed: (this._canAdd) ? () => _onAddActionClick() : null,
      ),
      // Cancel
      TextButton(child: new Text("Cancel"), onPressed: () => Navigator.of(context).pop()),
    ];
  }
}
