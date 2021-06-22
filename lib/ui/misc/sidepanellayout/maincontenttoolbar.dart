import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/ui/misc/VoltTextField.dart';
import 'package:voltlauncher/ui/misc/actionpopupmenuitem.dart';
import 'package:voltlauncher/ui/misc/exposed_popupmenu_button.dart';

/// A toolbar with multiple items.
///
/// Usually used with a [ListViewWithToolbar].
class MainContentToolbar extends StatelessWidget {
  /// The items.
  final List<Widget> children;

  /// Whether to automatically add spaces between the children.
  final bool automaticSpaces;

  MainContentToolbar({
    required this.children,
    this.automaticSpaces = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: this
          .children
          .expand((element) => [
                // Add a space if [automaticSpaces] is `true`
                ((this.children.indexOf(element) > 0) && (this.automaticSpaces)) ? MainContentToolbarItem.space() : SizedBox.shrink(),
                element,
              ])
          .toList(),
    );
  }
}

/// Items for [MainContentToolbar].
abstract class MainContentToolbarItem {
  /// A space that expands, filling the available space.
  static Widget expandedSpace() => Expanded(child: SizedBox.shrink());

  /// A space.
  static Widget space() => SizedBox(width: 8);

  /// A space with the size of a button. Useful for centering items.
  static Widget buttonSizedSpace() => SizedBox(width: 36);

  /// A button.
  static Widget button({required IconData icon, required String tooltip, required VoidCallback? onPressed}) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(36, 36), primary: Colors.grey[800]!.withAlpha(127)),
        child: Icon(icon, size: 16, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  /// A button that displays a list of items when pressed.
  static Widget menuButton({required List<ActionPopupMenuItem> menuItems}) {
    late ExposedPopupMenuButton popupMenuButton;
    return popupMenuButton = ExposedPopupMenuButton<int>(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(36, 36), primary: Colors.grey[800]!.withAlpha(127)),
        child: Icon(Icons.more_vert, size: 16, color: Colors.white),
        onPressed: () => popupMenuButton.showButtonMenu(),
      ),
      itemBuilder: (context) => menuItems,
      onSelected: (value) {
        menuItems.firstWhere((e) => e.value == value).onSelected?.call();
      },
    );
  }

  /// A TextField styled like a search bar.
  static Widget searchBar({required TextEditingController controller}) {
    return SizedBox(
      width: 200,
      height: 28,
      child: VoltTextField(
        controller: controller,
        suffixIcon: Icon(Icons.search, size: 16),
        hintText: 'Search',
      ),
    );
  }
}
