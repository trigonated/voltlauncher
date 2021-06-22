import 'package:flutter/material.dart';

// ignore: must_be_immutable
/// [PopupMenuButton] with an exposed [showButtonMenu] method.
class ExposedPopupMenuButton<T> extends PopupMenuButton<T> {
  PopupMenuButtonState<T>? get _currentState => (this.key as GlobalKey).currentState as PopupMenuButtonState<T>?;

  ExposedPopupMenuButton({
    itemBuilder,
    initialValue,
    onSelected,
    onCanceled,
    tooltip,
    elevation,
    padding = const EdgeInsets.all(8.0),
    child,
    icon,
    iconSize,
    offset = Offset.zero,
    enabled = true,
    shape,
    color,
    enableFeedback,
  }) : super(
          key: GlobalKey(),
          itemBuilder: itemBuilder,
          initialValue: initialValue,
          onSelected: onSelected,
          onCanceled: onCanceled,
          tooltip: tooltip,
          elevation: elevation,
          padding: padding,
          child: child,
          icon: icon,
          iconSize: iconSize,
          offset: offset,
          enabled: enabled,
          shape: shape,
          color: color,
          enableFeedback: enableFeedback,
        );

  void showButtonMenu() => _currentState?.showButtonMenu();
}
