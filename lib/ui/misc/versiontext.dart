import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Widget that displays the version of the application.
class VersionText extends StatelessWidget {
  /// If non-null, the style to use for this text.
  final TextStyle? style;

  VersionText({
    this.style,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        return Text(
          (snapshot.hasData) ? snapshot.data!.version : "",
          style: this.style,
        );
      },
    );
  }
}
