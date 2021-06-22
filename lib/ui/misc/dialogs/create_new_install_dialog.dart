import 'package:flutter/material.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/ui/misc/VoltTextField.dart';
import 'package:voltlauncher/ui/misc/dialogs/alert_custom_dialog.dart';
import 'package:voltlauncher/ui/misc/dialogs/custom_dialog.dart';

/// Dialog for creating a new install.
///
/// For convenience, the dialog takes care of creating the install,
/// returning the id of the newly created install.
class CreateNewInstallDialog extends CustomDialog {
  /// Callback for when the install is created.
  final void Function(String createdInstall) onNewInstallCreated;

  CreateNewInstallDialog({
    required this.onNewInstallCreated,
  }) : super(
          title: "Create new install",
        );

  /// Show the dialog.
  static show({
    required BuildContext context,
    required void Function(String createdInstall) onNewInstallCreated,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => CreateNewInstallDialog(onNewInstallCreated: onNewInstallCreated),
    );
  }

  @override
  State<StatefulWidget> createState() => _CreateNewInstallDialogState();
}

class _CreateNewInstallDialogState extends CustomDialogState<CreateNewInstallDialog> {
  /// See [_installName].
  late TextEditingController _installNameTextController;

  /// The name field.
  String get _installName => _installNameTextController.text;

  /// Whether the add action can be clicked.
  bool get _canAdd => (this._installName.trim().isNotEmpty);

  @override
  void initState() {
    super.initState();

    // Initialize the textfield controllers
    _installNameTextController = TextEditingController(text: null);
    _installNameTextController.addListener(() => setState(() {}));
  }

  /// Called when the add action is clicked.
  void _onAddActionClick() async {
    setState(() {
      this.isLoading = true;
    });
    // Create the install
    final bool result = await repository.local.createInstall(name: this._installName);
    if (result) {
      // Install created
      // Close the dialog and call the callback
      Navigator.of(context).pop();
      widget.onNewInstallCreated(this._installName);
    } else {
      // Install couldn't be created
      setState(() {
        this.isLoading = false;
      });
      AlertCustomDialog.show(context: context, message: "Error creating the install");
    }
  }

  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow(context, label: "Name:", child: _buildTextField(context, hintText: "Name", textFieldController: this._installNameTextController)),
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
