import 'package:flutter/material.dart';
import 'package:voltlauncher/model/misc/contentsource_getter.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/VoltTextField.dart';
import 'package:voltlauncher/ui/misc/dialogs/alert_custom_dialog.dart';
import 'package:voltlauncher/ui/misc/dialogs/custom_dialog.dart';

/// Dialog that prompts the user to add a source based on the Re-volt IO APIs.
///
/// This only obtains the source data, you still need to call [repository.sources.addSource]
/// to actually add the source.
class AddRevoltIOSourceDialog extends CustomDialog {
  /// The primary action.
  final void Function(ContentSource contentSource) addAction;

  AddRevoltIOSourceDialog({
    required this.addAction,
  }) : super(
          title: "Add Re-Volt I/O based source",
        );

  /// Show the dialog.
  static show({
    required BuildContext context,
    required void Function(ContentSource contentSource) addAction,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AddRevoltIOSourceDialog(addAction: addAction),
    );
  }

  @override
  State<StatefulWidget> createState() => _AddRevoltIOSourceDialogState();
}

class _AddRevoltIOSourceDialogState extends CustomDialogState<AddRevoltIOSourceDialog> {
  /// See [_sourceName].
  late TextEditingController _sourceNameTextController;

  /// The name field.
  String get _sourceName => this._sourceNameTextController.text;

  /// See [_sourceUrl].
  late TextEditingController _sourceUrlTextController;

  /// The url field.
  String get _sourceUrl => this._sourceUrlTextController.text;

  /// The source type field.
  ContentSourceType _selectedSourceType = ContentSourceType.unknown;

  /// Whether the add action can be clicked.
  bool get _canAdd => ((this._sourceName.trim().isNotEmpty) && (this._sourceUrl.trim().isNotEmpty) && (this._selectedSourceType != ContentSourceType.unknown));

  @override
  void initState() {
    super.initState();

    // Initialize the textfield controllers
    _sourceNameTextController = TextEditingController(text: null);
    _sourceNameTextController.addListener(() => setState(() {}));
    _sourceUrlTextController = TextEditingController(text: null);
    _sourceUrlTextController.addListener(() => setState(() {}));
  }

  /// Called when the add action is clicked.
  void _onAddActionClick() async {
    setState(() {
      this.isLoading = true;
    });
    // Try to create the source
    ContentSource? contentSource = await ContentSourceGetter.getRevoltIOContentSource(
      name: this._sourceName,
      type: this._selectedSourceType,
      url: this._sourceUrl,
    );
    if (contentSource != null) {
      // Source was created successfully
      // Close the dialog and call the callback
      Navigator.of(context).pop();
      widget.addAction(contentSource);
    } else {
      // Couldn't create the source
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
        _buildRow(context, label: "Name:", child: _buildTextField(context, hintText: "Name", textFieldController: this._sourceNameTextController)),
        SizedBox(height: 8),
        _buildRow(context, label: "Type:", child: _buildSourceTypeButton(context)),
        SizedBox(height: 8),
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
      ),
    );
  }

  /// Build a source type picker button.
  Widget _buildSourceTypeButton(BuildContext context) {
    return Container(
      width: 240,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: const BorderRadius.all(Radius.circular(4.0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ContentSourceType>(
          value: this._selectedSourceType,
          isExpanded: true,
          items: [
            // Special default item that disappears after another item being selected
            if (this._selectedSourceType == ContentSourceType.unknown)
              DropdownMenuItem<ContentSourceType>(
                value: ContentSourceType.unknown,
                child: Text(
                  "Select a type",
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                ),
              ),
            // Normal items
            DropdownMenuItem<ContentSourceType>(
              value: ContentSourceType.repository,
              child: Text(
                "Pack repository",
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            DropdownMenuItem<ContentSourceType>(
              value: ContentSourceType.events_source,
              child: Text(
                "Events source",
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            DropdownMenuItem<ContentSourceType>(
              value: ContentSourceType.news_source,
              child: Text(
                "News source",
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              this._selectedSourceType = value ?? ContentSourceType.unknown;
            });
          },
          hint: Text("Type"),
        ),
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
