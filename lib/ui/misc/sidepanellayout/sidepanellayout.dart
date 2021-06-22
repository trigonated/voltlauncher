import 'package:flutter/material.dart';
import 'package:voltlauncher/ui/misc/sidepanellayout/sidepanel.dart';

/// A widget which shows two columns: a large [mainContent] on the left
/// and a smaller [sidePanelContent] on the right.
///
/// [sidePanelHasContent] can be set to `false` to reduce the opacity of
/// the side panel.
class SidePanelLayout extends StatelessWidget {
  /// The main content, displayed on the left.
  final Widget mainContent;

  /// Whether the sidepanel has content.
  final bool sidePanelHasContent;

  /// The content of the side panel, displayed on the right.
  final Widget sidePanelContent;

  SidePanelLayout({
    required this.mainContent,
    this.sidePanelHasContent = true,
    required this.sidePanelContent,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main content
        Expanded(
          child: this.mainContent,
        ),
        // Side panel
        Padding(
          padding: EdgeInsets.all(24),
          child: SidePanel(
            width: 320,
            hasContent: this.sidePanelHasContent,
            child: this.sidePanelContent,
          ),
        ),
      ],
    );
  }
}
