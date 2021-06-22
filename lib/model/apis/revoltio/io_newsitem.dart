import 'package:intl/intl.dart';
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';

/// A news item from the Re-volt IO API.
/// This corresponds to the API's corresponding json object.
class IONewsItem {
  final IONewsItemExtraData extraData;
  final String title;
  final DateTime date;
  final List<String>? tag;
  final String? content;

  IONewsItem({
    required this.extraData,
    required this.title,
    required this.date,
    required this.tag,
    required this.content,
  });

  static IONewsItem? fromJson({required NewsSource source, required String? url, required Map<String, dynamic> json}) {
    DateFormat dateFormat = new DateFormat("dd-MM-yyyy hh:mm");
    DateFormat dateFormatAlt = new DateFormat("hh:mm dd-MM-yyyy");
    DateTime date;
    if (json['header']['date'] != null) {
      try {
        date = dateFormat.parse(json['header']['date']);
      } catch (e) {
        try {
          date = dateFormatAlt.parse(json['header']['date']);
        } catch (e) {
          return null;
        }
      }
    } else {
      return null;
    }
    return IONewsItem(
      extraData: IONewsItemExtraData(
        source: source,
        url: url,
      ),
      title: json['header']['title'],
      date: date,
      tag: json['header']['taxonomy']?['tag']?.map<String>((e) => e as String).toList(),
      content: json['content'],
    );
  }

  NewsItem toNewsItem() {
    return NewsItem(
      source: this.extraData.source,
      url: this.extraData.url,
      title: this.title,
      description: this.content,
      tags: this.tag ?? [],
      imageUrl: null,
      date: this.date,
    );
  }
}

class IONewsItemExtraData {
  final NewsSource source;
  final String? url;

  IONewsItemExtraData({required this.source, required this.url});
}
