import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_control/window_control.dart';

/// Widget that defines an area of the title bar that can
/// be dragged or double-clicked to maximize/restore the window.
class TitleBarCaption extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TitleBarCaptionState();
}

class _TitleBarCaptionState extends State<TitleBarCaption> {
  /// Time when the pointer was last clicked on this widget.
  late int _lastTitleBarPointerDownTime;

  @override
  void initState() {
    super.initState();
    _lastTitleBarPointerDownTime = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        int time = DateTime.now().millisecondsSinceEpoch;
        // If the pointer was previously clicked on the same position and less than 500ms ago,
        // consider it a double-click.
        if (time < _lastTitleBarPointerDownTime + 500) {
          WindowControl.windowTitleDoubleTap();
        } else {
          // If not, start dragging the window. The window control lib takes care of stopping the
          // drag automatically.
          WindowControl.startDrag();
        }
        _lastTitleBarPointerDownTime = time;
      },
      onPointerMove: (_) {
        _lastTitleBarPointerDownTime = 0;
      },
      child: Container(
        color: Colors.transparent,
      ),
    );
  }
}
