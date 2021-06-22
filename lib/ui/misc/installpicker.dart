import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/model/objects/sources/presetssource.dart';

/// Widget that displays a list of installs and lets the user pick one.
class InstallPicker extends StatefulWidget {
  final Future<List<String>>? installsFuture;
  final String? selectedInstall;
  final void Function(String? selectedInstall)? onSelectedInstallChanged;

  InstallPicker({
    required this.installsFuture,
    required this.selectedInstall,
    required this.onSelectedInstallChanged,
  });

  @override
  State<StatefulWidget> createState() => _InstallPickerState();
}

class _InstallPickerState extends State<InstallPicker> {
  String? _selectedInstall;

  @override
  void initState() {
    super.initState();

    this._selectedInstall = widget.selectedInstall;
  }

  /// Called when an item is tapped.
  void _onItemTap(String item) {
    if (item != widget.selectedInstall) {
      setState(() {
        this._selectedInstall = item;
        if (widget.onSelectedInstallChanged != null) {
          widget.onSelectedInstallChanged!(item);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: FutureBuilder<List<String>>(
        future: widget.installsFuture,
        builder: (context, snapshot) {
          if ((snapshot.connectionState == ConnectionState.done) && (snapshot.hasData)) {
            // Data is loaded

            // Filter out the presets sources
            final List<String> data = snapshot.data!.where((e) => (!(e is PresetsSource))).toList();
            return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildItem(
                    context,
                    index: index,
                    install: data[index],
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
  Widget _buildItem(BuildContext context, {required int index, required String install}) {
    return Container(
      height: 32,
      color: (this._selectedInstall == install)
          ? Colors.white.withAlpha(0x5F) // Selected item
          : ((index % 2 == 0)
              ? Colors.transparent // Even
              : Colors.grey.withAlpha(0x1F) // Odd
          ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onItemTap(install),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 8),
              Text(install),
            ],
          ),
        ),
      ),
    );
  }
}
