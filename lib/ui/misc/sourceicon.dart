import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';

/// Widget that displays the icon of a source.
class SourceIcon extends StatelessWidget {
  final ContentSource source;
  final double? size;

  SourceIcon({
    required this.source,
    this.size,
  }) : super();

  @override
  Widget build(BuildContext context) {
    if (source.iconUrl != null) {
      return FadeInImage.assetNetwork(placeholder: Assets.graphics.source_default, image: source.iconUrl!, width: this.size, height: this.size);
    } else {
      return Image.asset(Assets.graphics.source_default, width: this.size, height: this.size);
    }
  }
}
