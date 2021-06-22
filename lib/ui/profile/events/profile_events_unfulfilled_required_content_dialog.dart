import 'package:flutter/material.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/model/objects/events/event_contentrequirement.dart';
import 'package:voltlauncher/model/objects/events/event_contentrequirementfailure.dart';
import 'package:voltlauncher/ui/misc/dialogs/custom_dialog.dart';

/// Dialog that displays a list of unfulfilled required content of an event.
class ProfileEventsUnfulfilledRequiredContentDialog extends CustomDialog {
  final Event event;

  ProfileEventsUnfulfilledRequiredContentDialog({
    required this.event,
  }) : super(
          title: null,
        );

  @override
  State<StatefulWidget> createState() => _ProfileEventsUnfulfilledRequiredContentDialogState();
}

class _ProfileEventsUnfulfilledRequiredContentDialogState extends CustomDialogState<ProfileEventsUnfulfilledRequiredContentDialog> {
  @override
  Widget buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Description
        Text("The following content is missing or outdated:"),
        SizedBox(height: 8),
        // List
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.event.unfulfilledRequiredContent.map((e) => _buildItem(context, item: e)).toList(),
        ),
      ],
    );
  }

  /// Build an item of the list.
  static Widget _buildItem(BuildContext context, {required EventContentRequirementFailure item}) {
    switch (item.type) {
      case EventContentRequirementType.pack:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon((item.installedVersion != null) ? Icons.arrow_circle_up : Icons.extension, size: 16),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(" Pack: " + item.name + ((item.installedVersion != null) ? " (Update required)" : "")),
              ),
            ),
          ],
        );
      case EventContentRequirementType.track:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.terrain, size: 16),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(" Track: " + item.name),
              ),
            ),
          ],
        );
      case EventContentRequirementType.car:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 16),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text(" Car: " + item.name),
              ),
            ),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      TextButton(child: new Text("OK"), onPressed: () => Navigator.of(context).pop()),
    ];
  }
}
