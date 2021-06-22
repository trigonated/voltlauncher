import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/model/objects/sources/newssource.dart';

/// A news item (article).
class NewsItem {
  /// The source.
  final NewsSource source;

  /// The item's url. This is the webpage of the item.
  final String? url;

  /// The title.
  final String title;

  /// The description for this item.
  final String? description;

  /// Tags related to the item.
  final List<String> tags;

  /// The url of the item's image.
  final String? imageUrl;

  /// The date of the article.
  final DateTime date;

  NewsItem({
    required this.source,
    required this.url,
    required this.title,
    required this.description,
    required this.tags,
    required this.imageUrl,
    required this.date,
  });

  static Future<NewsItem> fromJson(Map<String, dynamic> json) async {
    return NewsItem(
      source: (await repository.sources.fetchNewsSource(url: json['source']))!,
      url: json['url'],
      title: json['title'],
      description: json['description'],
      tags: json['tags']?.map<String>((e) => e as String).toList() ?? [],
      imageUrl: json['imageUrl'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': this.source.url,
      'url': this.url,
      'title': this.title,
      'description': this.description,
      'tags': this.tags,
      'imageUrl': this.imageUrl,
      'date': this.date.toString(),
    };
  }
}
