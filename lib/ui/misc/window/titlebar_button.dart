import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A window title bar button (minimize, maximize, close, etc).
///
/// When [isCloseButton] is `true`, the button takes a slightly
/// different styling.
class TitleBarButton extends StatefulWidget {
  /// The icon of the button.
  final IconData icon;

  /// Whether this is a close button, with a different style.
  final bool isCloseButton;

  /// Callback for when the button is pressed.
  final VoidCallback onPressed;

  TitleBarButton({
    required this.icon,
    this.isCloseButton = false,
    required this.onPressed,
  }) : super();

  @override
  State<StatefulWidget> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<TitleBarButton> {
  /// Whether the button is being hovered.
  late bool _isHovered;

  /// Whether the button is being pressed.
  late bool _isPressed;

  /// The color of the button when it's being hovered.
  Color get _color => (widget.isCloseButton) ? Color(0xFFD32F2F) : Color(0xFF404040);

  /// The color of the button when it's being pressed.
  Color get _colorPressed => (widget.isCloseButton) ? Color(0xFFB71C1C) : Color(0xFF202020);

  /// The color of the button on it's normal state.
  Color get _colorTransparent => _color.withAlpha(0);

  @override
  void initState() {
    super.initState();

    _isHovered = false;
    _isPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: MouseRegion(
        onEnter: (_) => setState(() {
          _isHovered = true;
        }),
        onExit: (_) => setState(() {
          _isHovered = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() {
            _isPressed = true;
          }),
          onTapUp: (_) => setState(() {
            _isPressed = false;
            widget.onPressed.call();
          }),
          onTapCancel: () => setState(() {
            _isPressed = false;
          }),
          child: AnimatedContainer(
            alignment: Alignment.center,
            width: 46,
            height: 30,
            curve: Curves.easeOut,
            duration: Duration(milliseconds: 200),
            color: (_isPressed)
                ? _colorPressed // Pressed
                : (_isHovered)
                    ? _color // Hovered
                    : _colorTransparent, // Normal
            child: Icon(
              widget.icon,
              color: const Color(0xffcccccc),
              size: 16,
            ),
          ),
        ),
      ),
    );
  }
}
