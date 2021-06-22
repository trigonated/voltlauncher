import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/ui/misc/translucentcard.dart';

/// Widget used to wrap "items".
///
/// Using this instead of using a [TranslucentCard] is recommended
/// to make possible future changes to items easier.
class ItemContainer extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;

  ItemContainer({
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.all(TranslucentCard.defaultMargin),
    this.borderRadius = const BorderRadius.all(TranslucentCard.defaultRadius),
  }) : super();

  @override
  Widget build(BuildContext context) {
    return TranslucentCard(
      child: this.child,
      onTap: this.onTap,
      margin: this.margin,
      borderRadius: this.borderRadius,
    );
  }
}
