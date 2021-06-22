import 'package:flutter/material.dart';

/// Wrapper around [TextField] to automatically apply the
/// app's own style.
class VoltTextField extends TextField {
  VoltTextField({
    required TextEditingController? controller,
    String? hintText,
    Widget? suffixIcon,
  }) : super(
          controller: controller,
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
            filled: true,
            fillColor: Colors.grey[800]!.withAlpha(127),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white12, width: 1),
            ),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(),
            suffixIcon: suffixIcon,
            hintText: hintText,
          ),
        );
}
