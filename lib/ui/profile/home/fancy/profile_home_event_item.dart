import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/stringutils.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/ui/misc/eventimage.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';
import 'package:voltlauncher/ui/misc/sourceindicator.dart';

/// A "large" event item.
class ProfileHomeEventItem extends StatefulWidget {
  final Event event;
  final void Function(Event event) onTap;

  ProfileHomeEventItem({Key? key, required this.event, required this.onTap}) : super(key: key);

  @override
  _ProfileHomeEventItemState createState() => _ProfileHomeEventItemState();
}

class _ProfileHomeEventItemState extends State<ProfileHomeEventItem> {
  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      onTap: () => widget.onTap.call(widget.event),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image
        EventImage(event: widget.event),
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
                      // Date
                      Expanded(
                        child: Text(
                          StringUtils.generatePrettyDate(widget.event.date).toUpperCase(),
                          style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Source
                      SourceIndicator(source: widget.event.source),
                    ],
                  ),
                ),
                // Title
                Text(
                  widget.event.title,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                // Description
                Expanded(
                  child: Text(
                    widget.event.description ?? "No description",
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
