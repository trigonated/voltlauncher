/// A list that contains headers.
class HeadedList<T> {
  /// The items. Items can be either [HeadedListHeaderItem] or [HeadedListNormalItem].
  List<HeadedListItem> items;

  HeadedList({required this.items});

  /// Create an headed list from a [list] of items.
  ///
  /// Each key of [header] represents an header and it's value is a function
  /// that returns `true` on items that belong under that header.
  factory HeadedList.fromList(
    List<T> list, {
    required Map<String, bool Function(T element)> headers,
  }) {
    List<HeadedListItem> items = List.empty(growable: true);

    // Build the list by going through each header
    for (var header in headers.entries) {
      bool addedHeader = false;
      for (var i = 0; i < list.length; i++) {
        if ((header.value(list[i])) && (!items.any((e) => ((e is HeadedListNormalItem) && (e.itemIndex == i))))) {
          // The header item goes first
          if (!addedHeader) {
            addedHeader = true;
            items.add(HeadedListItem.header(title: header.key));
          }
          // Followed by the header's items
          items.add(HeadedListItem.normalItem(itemIndex: i));
        }
      }
    }

    return HeadedList<T>(items: items);
  }
}

class HeadedListItem {
  HeadedListItem();

  factory HeadedListItem.header({required String title}) => HeadedListHeaderItem(title: title);

  factory HeadedListItem.normalItem({required int itemIndex}) => HeadedListNormalItem(itemIndex: itemIndex);
}

class HeadedListHeaderItem extends HeadedListItem {
  final String title;

  HeadedListHeaderItem({required this.title}) : super();
}

class HeadedListNormalItem extends HeadedListItem {
  final int itemIndex;

  HeadedListNormalItem({required this.itemIndex}) : super();
}
