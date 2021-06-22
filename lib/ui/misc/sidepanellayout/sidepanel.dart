import 'package:flutter/material.dart';
import 'package:voltlauncher/ui/misc/translucentcard.dart';

/// The side panel from the [SidePanelLayout] that displays the
/// content set on [child].
///
/// [hasContent] controls the opacity of this widget, reducing
/// it's alpha when [hasContent] is `false`.
class SidePanel extends StatefulWidget {
  final double width;
  final bool hasContent;
  final Widget child;

  SidePanel({
    required this.width,
    this.hasContent = true,
    required this.child,
  }) : super();

  @override
  State<StatefulWidget> createState() => _SidePanelState();
}

class _SidePanelState extends State<SidePanel> {
  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: widget.hasContent ? 1 : 0.25, // Reduce the opacity if [hasContent] is false
      duration: Duration(milliseconds: 500),
      child: Container(
        width: widget.width,
        child: TranslucentCard(
          child: widget.child,
        ),
      ),
    );
  }
}
