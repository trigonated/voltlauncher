import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// PopupMenuItem that contains a callback for when it's selected.
/// 
/// It's value is the object's hashcode.
class ActionPopupMenuItem extends PopupMenuItem<int> {
  final VoidCallback? onSelected;

  int? get value => this.hashCode;

  ActionPopupMenuItem({
    bool enabled = true,
    required Widget child,
    required this.onSelected,
  }) : super(enabled: enabled, child: child);
}
