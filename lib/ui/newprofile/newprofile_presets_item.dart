import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/model/objects/profiles/profilepreset.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';
import 'package:voltlauncher/ui/misc/sourceindicator.dart';
import 'package:voltlauncher/ui/newprofile/profilepresetimage.dart';

/// Item representing a profile preset.
class NewProfilePresetsItem extends StatefulWidget {
  /// The preset.
  final ProfilePreset preset;

  /// Callback for when the item is tapped.
  final void Function(ProfilePreset preset) onTap;

  /// Callback for when the optional content checkbox is checked/unchecked.
  final void Function(ProfilePreset preset, bool checked) onOptionalContentCheckedChanged;

  NewProfilePresetsItem({Key? key, required this.preset, required this.onTap, required this.onOptionalContentCheckedChanged}) : super(key: key);

  @override
  _NewProfilePresetsItemState createState() => _NewProfilePresetsItemState();
}

class _NewProfilePresetsItemState extends State<NewProfilePresetsItem> {
  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      onTap: () => widget.onTap.call(widget.preset),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image
        ProfilePresetImage(preset: widget.preset),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Row(
                    children: [
                      // Name
                      Expanded(
                        child: Text(
                          widget.preset.name,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Source
                      ((widget.preset.source != null) && (widget.preset.source!.sourceProfileId == null))
                          ? SourceIndicator(source: widget.preset.source!)
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
                // Description
                Expanded(
                  child: Text(
                    widget.preset.description ?? "No description",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
                // Optional content checkbox
                (widget.preset.hasOptionalContent)
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            activeColor: Colors.orange,
                            value: widget.preset.optionalContentChecked,
                            onChanged: (value) {
                              setState(() {
                                widget.preset.optionalContentChecked = value ?? false;
                                widget.onOptionalContentCheckedChanged(widget.preset, value ?? false);
                              });
                            },
                          ),
                          SizedBox(width: 8),
                          Text(widget.preset.optionalContentLabel ?? "Optional content"),
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
