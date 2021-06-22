import 'dart:ui';

import 'package:flutter/material.dart';

/// Material card with some translucency and a blur effect.
class TranslucentCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final BorderRadius borderRadius;
  static const double defaultMargin = 4.0;
  static const Radius defaultRadius = Radius.circular(6.0);

  TranslucentCard({
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.all(TranslucentCard.defaultMargin),
    this.borderRadius = const BorderRadius.all(TranslucentCard.defaultRadius),
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: this.margin,
      color: Colors.grey[800]!.withAlpha(127),
      child: ClipRRect(
        borderRadius: this.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Material(
            color: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            child: (this.onTap != null)
                ? InkWell(
                    onTap: this.onTap,
                    child: this.child,
                  )
                : this.child,
          ),
        ),
      ),
    );
  }
}
