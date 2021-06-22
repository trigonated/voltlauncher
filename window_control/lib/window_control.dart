import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';

/// Library to control the window.
class WindowControl {
  static const MethodChannel _channel = const MethodChannel("window_control");

  /// Get whether this library is supported on this system.
  static bool get isSupported => Platform.isWindows;

  /// Show the title bar.
  static Future showTitleBar() {
    return _channel.invokeMethod<bool>("showTitleBar");
  }

  /// Hide the title bar.
  static Future<bool?> hideTitleBar() {
    return _channel.invokeMethod<bool>("hideTitleBar");
  }

  /// Close the window.
  static Future<bool?> closeWindow() {
    return _channel.invokeMethod<bool>("closeWindow");
  }

  /// Minimize the window.
  static Future<bool?> minimizeWindow() {
    return _channel.invokeMethod<bool>("minimizeWindow");
  }

  /// Maximize the window.
  static Future<bool?> maximizeWindow() {
    return _channel.invokeMethod<bool>("maximizeWindow");
  }

  /// Center the window on the screen.
  static Future<bool?> centerWindow() {
    return _channel.invokeMethod<bool>("centerWindow");
  }

  /// Set the position of the window.
  static Future<bool?> setWindowPosition(Offset offset) {
    return _channel.invokeMethod<bool>("setWindowPosition", {
      "x": offset.dx,
      "y": offset.dy,
    });
  }

  /// Get the position of the window.
  static Future<Offset?> getWindowPosition() async {
    final _data = await _channel.invokeMethod<Map>("getWindowPosition");
    if (_data != null) {
      return Offset(_data["x"] as double, _data["y"] as double);
    } else {
      return null;
    }
  }

  /// Set the size of the window.
  static Future<bool?> setWindowSize(Size size) {
    return _channel.invokeMethod<bool>("setWindowSize", {
      "width": size.width,
      "height": size.height,
    });
  }

  /// Get the size of the window.
  static Future<Size?> getWindowSize() async {
    final _data = await _channel.invokeMethod<Map>("getWindowSize");
    if (_data != null) {
      return Size(_data["width"] as double, _data["height"] as double);
    } else {
      return null;
    }
  }

  /// Start dragging the window.
  static Future<bool?> startDrag() {
    return _channel.invokeMethod<bool>("startDrag");
  }

  /// Start resizing the window.
  static Future<bool?> startResize(DragPosition position) {
    return _channel.invokeMethod<bool>(
      "startResize",
      {
        "top": position == DragPosition.top || position == DragPosition.topLeft || position == DragPosition.topRight,
        "bottom": position == DragPosition.bottom || position == DragPosition.bottomLeft || position == DragPosition.bottomRight,
        "right": position == DragPosition.right || position == DragPosition.topRight || position == DragPosition.bottomRight,
        "left": position == DragPosition.left || position == DragPosition.topLeft || position == DragPosition.bottomLeft,
      },
    );
  }

  /// Execute the double-tap behaviour on the window.
  static Future<bool?> windowTitleDoubleTap() {
    return _channel.invokeMethod<bool>("windowTitleDoubleTap");
  }

  /// Get the size of the screen.
  static Future<Size?> getScreenSize() async {
    final _data = await _channel.invokeMethod<Map>("getScreenSize");
    if (_data != null) {
      return Size(_data["width"] as double, _data["height"] as double);
    } else {
      return null;
    }
  }
}

enum DragPosition { top, left, right, bottom, topLeft, bottomLeft, topRight, bottomRight }
