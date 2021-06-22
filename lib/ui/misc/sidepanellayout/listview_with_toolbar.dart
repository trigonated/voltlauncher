import 'package:flutter/widgets.dart';

/// [ListView] with a toolbar at the top, ideally a [MainContentToolbar].
abstract class ListViewWithToolbar extends ListView {
  static ListView builder({
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    required Widget toolbar,
    required int itemCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return ListView.builder(
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount + 1, // +1 to account for the toolbar at the top
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            // First item is the toolbar
            return toolbar;
          } else {
            // Other items are the normal items
            return itemBuilder(context, index - 1);
          }
        });
  }
}
