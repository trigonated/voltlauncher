import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/ui/misc/sourceicon.dart';

/// Widget that displays the icon and the name of a source.
///
/// Use [useUniqueName] to display suffixes like "(Events)"
/// in front of the source's name. Useful in situations where
/// multiple sources with the same name may be shown.
class SourceIndicator extends StatelessWidget {
  final ContentSource source;
  final bool useUniqueName;

  SourceIndicator({
    required this.source,
    this.useUniqueName = false,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SourceIcon(source: this.source, size: 16),
        SizedBox(width: 4),
        Text(
          (this.useUniqueName) ? this.source.uniqueName : this.source.name,
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}
