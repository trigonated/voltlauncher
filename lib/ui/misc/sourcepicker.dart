import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';
import 'package:voltlauncher/ui/misc/sourceicon.dart';

/// Widget that displays a list of sources.
class SourcePicker extends StatefulWidget {
  /// The list of sources.
  final Future<List<ContentSource>>? sourcesFuture;

  /// Whether to show or hide the presets sources.
  final bool showPresetsSources;

  // Checkbox-related

  /// Whether to show checkboxes on the left.
  final bool showCheckboxes;

  /// Function that defines what sources are enabled (checked).
  final bool Function(ContentSource source)? enabledSources;

  /// Callback for when a source is enabled/disabled.
  final void Function(ContentSource source, bool enabled)? onSourceEnabledChanged;

  // Selectable-related

  /// Whether a source can be selected.
  final bool selectable;

  /// The selected source.
  final ContentSource? selectedSource;

  /// Callback for when the selected source is changed to another one.
  final void Function(ContentSource? selectedSource)? onSelectedSourceChanged;

  SourcePicker({
    required this.sourcesFuture,
    required this.showCheckboxes,
    required this.enabledSources,
    required this.onSourceEnabledChanged,
    required this.selectable,
    required this.selectedSource,
    required this.onSelectedSourceChanged,
    this.showPresetsSources = true,
  });

  /// List of sources with checkboxes, allowing the
  /// user to enable/disable sources.
  ///
  /// [enabledSources] defines what sources are enabled (checked).
  ///
  /// If [showPresetsSources] is `false`, presets sources are hidden.
  factory SourcePicker.withCheckboxes({
    required Future<List<ContentSource>>? sourcesFuture,
    required bool Function(ContentSource source) enabledSources,
    required void Function(ContentSource source, bool enabled) onSourceEnabledChanged,
    bool showPresetsSources = true,
  }) {
    return SourcePicker(
      sourcesFuture: sourcesFuture,
      showCheckboxes: true,
      enabledSources: enabledSources,
      onSourceEnabledChanged: onSourceEnabledChanged,
      selectable: false,
      selectedSource: null,
      onSelectedSourceChanged: null,
      showPresetsSources: showPresetsSources,
    );
  }

  /// List of sources, allowing the user to select one.
  ///
  /// If [showPresetsSources] is `false`, presets sources are hidden.
  factory SourcePicker.selectable({
    required Future<List<ContentSource>>? sourcesFuture,
    required ContentSource? selectedSource,
    required void Function(ContentSource? selectedSource)? onSelectedSourceChanged,
    bool showPresetsSources = true,
  }) {
    return SourcePicker(
      sourcesFuture: sourcesFuture,
      showCheckboxes: false,
      enabledSources: null,
      onSourceEnabledChanged: null,
      selectable: true,
      selectedSource: selectedSource,
      onSelectedSourceChanged: onSelectedSourceChanged,
      showPresetsSources: showPresetsSources,
    );
  }

  @override
  State<StatefulWidget> createState() => _SourcePickerState();
}

class _SourcePickerState extends State<SourcePicker> {
  ContentSource? _selectedSource;

  @override
  void initState() {
    super.initState();

    this._selectedSource = widget.selectedSource;
  }

  /// Gets whether a source is enabled.
  bool _isSourceEnabled(ContentSource source) {
    return (widget.enabledSources != null) ? widget.enabledSources!(source) : true;
  }

  /// Called when an item's checkbox is changed.
  void _onItemCheckboxChanged(ContentSource item, bool? value) {
    if (widget.onSourceEnabledChanged != null) {
      widget.onSourceEnabledChanged!(item, value ?? false);
    }
  }

  /// Called when an item is tapped.
  void _onItemTap(ContentSource item) {
    if (widget.selectable) {
      // Select the item
      if (item != this._selectedSource) {
        setState(() {
          this._selectedSource = item;
          if (widget.onSelectedSourceChanged != null) {
            widget.onSelectedSourceChanged!(item);
          }
        });
      }
    } else if (widget.showCheckboxes) {
      // Toggle the checkbox
      _onItemCheckboxChanged(item, !_isSourceEnabled(item));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: FutureBuilder<List<ContentSource>>(
        future: widget.sourcesFuture,
        builder: (context, snapshot) {
          if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
            // Data is loaded

            // Filter out the presets sources (if applicable)
            final List<ContentSource> data = snapshot.data!.where((e) => ((!(e is PresetsSource)) || (widget.showPresetsSources))).toList();
            // Build the list
            return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(
                    context,
                    index: index,
                    source: data[index],
                    enabled: _isSourceEnabled(data[index]),
                  );
                });
          } else if (snapshot.hasError) {
            // Error
            return Text("${snapshot.error}");
          } else {
            // Loading
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

  /// Build an item.
  Widget _buildItem(BuildContext context, {required int index, required ContentSource source, required bool enabled}) {
    return Container(
      height: 32,
      color: (this._selectedSource == source)
          ? Colors.white.withAlpha(0x5F) // Selected item
          : ((index % 2 == 0)
              ? Colors.transparent // Even
              : Colors.grey.withAlpha(0x1F) // Odd
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTap(source),
          child: Opacity(
            // Disabled sources are transparent
            opacity: ((source.universe == null) || (_isSourceEnabled(source.universe!))) ? 1 : 0.25,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Items that are under an universe have a left margin
                SizedBox(width: (source.universe != null) ? 24 : 0),
                // Checkbox
                (widget.showCheckboxes)
                    ? Checkbox(
                        activeColor: Colors.orange,
                        value: enabled,
                        onChanged: (value) => _onItemCheckboxChanged(source, value),
                      )
                    : SizedBox.shrink(),
                // Icon
                SizedBox(width: 8),
                SourceIcon(source: source, size: 16),
                // Name
                SizedBox(width: 8),
                Text(source.uniqueName),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
