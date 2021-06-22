import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/stringutils.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/ui/misc/eventimage.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';

/// A "small" (to be used on a list) event item.
class ProfileHomeEventItemSmall extends StatefulWidget {
  final Event event;
  final void Function(Event event) onTap;

  ProfileHomeEventItemSmall({Key? key, required this.event, required this.onTap}) : super(key: key);

  @override
  _ProfileHomeEventItemSmallState createState() => _ProfileHomeEventItemSmallState();
}

class _ProfileHomeEventItemSmallState extends State<ProfileHomeEventItemSmall> {
  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      onTap: () => widget.onTap.call(widget.event),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image
        EventImage(event: widget.event),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
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
                          style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Title
                Text(
                  widget.event.title,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
