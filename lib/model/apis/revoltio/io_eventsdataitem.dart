
/// An item of the list of events from the Re-volt IO API.
/// This corresponds to the API's corresponding json object.
class IOEventsDataItem {
  final String url;

  IOEventsDataItem({required this.url});

  factory IOEventsDataItem.fromJson(Map<String, dynamic> json) {
    return IOEventsDataItem(
      url: json['url'],
    );
  }
}