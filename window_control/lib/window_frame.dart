import 'package:flutter/material.dart';
import 'package:window_control/window_control.dart';

/// Frame that resizes the window when interacted with.
class WindowsFrame extends StatelessWidget {
  final Widget child;
  final bool active;
  final BoxBorder? border;

  const WindowsFrame({
    Key? key,
    required this.child,
    required this.active,
    this.border,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!active) return child;
    // Dimensions of the draggable part
    final width = 4.0;
    final height = 4.0;
    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Border decoration (visual only)
          (border != null)
              ? Container(
                  decoration: BoxDecoration(border: border),
                  child: child,
                )
              : child,
          // Top
          Positioned(
            top: 0,
            left: width,
            right: width,
            height: height,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.top),
            ),
          ),
          // Bottom
          Positioned(
            bottom: 0,
            left: width,
            right: width,
            height: height,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.bottom),
            ),
          ),
          // Right
          Positioned(
            bottom: height,
            top: height,
            right: 0,
            width: width,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.right),
            ),
          ),
          // Left
          Positioned(
            bottom: height,
            top: height,
            left: 0,
            width: width,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.left),
            ),
          ),
          // Top-left
          Positioned(
            top: 0,
            left: 0,
            height: height,
            width: width,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.topLeft),
            ),
          ),
          // Top-right
          Positioned(
            top: 0,
            right: 0,
            height: height,
            width: width,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.topRight),
            ),
          ),
          // Bottom-left
          Positioned(
            bottom: 0,
            left: 0,
            height: height,
            width: width,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.bottomLeft),
            ),
          ),
          // Bottom-right
          Positioned(
            bottom: 0,
            right: 0,
            height: height,
            width: width,
            child: GestureDetector(
              onTapDown: (_) => WindowControl.startResize(DragPosition.bottomRight),
            ),
          ),
        ],
      ),
    );
  }
}
