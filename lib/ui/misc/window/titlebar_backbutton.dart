import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A back button used to return to the previous page.
class TitleBarBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  TitleBarBackButton({
    required this.onPressed,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        primary: Colors.white,
        padding: EdgeInsets.all(4),
        minimumSize: null,
      ),
      child: Icon(
        Icons.arrow_back,
        color: Colors.white,
        size: 16,
      ),
      onPressed: () => this.onPressed(),
    );
  }
}
