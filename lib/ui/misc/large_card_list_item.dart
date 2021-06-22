import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';
import 'package:voltlauncher/ui/misc/sourceindicator.dart';

/// "Large" list item that contains an image on the left
/// and some data on the right.
class LargeCardListItem extends StatelessWidget {
  /// The image shown on the left.
  final Widget image;

  /// The title.
  final String title;

  /// The subtitle show above the title.
  final String subtitle;

  /// The description.
  final String description;

  /// The source of the content, shown as an icon and name.
  final ContentSource? source;

  /// Tap callback.
  final VoidCallback onTap;

  LargeCardListItem({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.description,
    this.source,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      onTap: () => this.onTap.call(),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image on the left
        this.image,
        // Content on the right
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Row(
                    children: [
                      // Subtitle
                      Expanded(
                        child: Text(
                          this.subtitle.toUpperCase(),
                          style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Source
                      if (this.source != null) SourceIndicator(source: this.source!),
                    ],
                  ),
                ),
                // Title
                Text(this.title, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                // Description
                Expanded(
                  child: Text(
                    this.description,
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
