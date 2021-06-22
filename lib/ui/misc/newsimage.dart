import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/ui/misc/sourceicon.dart';

/// Image widget that displays the image of an [NewsItem].
class NewsImage extends StatelessWidget {
  final NewsItem newsItem;

  NewsImage({
    required this.newsItem,
  });

  @override
  Widget build(BuildContext context) {
    if (this.newsItem.imageUrl != null) {
      // Load the news item's image
      return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: FadeInImage.assetNetwork(
          placeholder: Assets.graphics.news.news_loading,
          image: this.newsItem.imageUrl!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // News item doesn't have an image url
      return _buildFallbackImage(context);
    }
  }

  // Build a fallback image.
  Widget _buildFallbackImage(BuildContext context) {
    // Pick a semi-random default image
    final String imageAsset =
        Assets.graphics.news.news_default(this.newsItem.title.length + this.newsItem.date.day + this.newsItem.date.millisecondsSinceEpoch);
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Stack(
        children: [
          // Image
          Image(image: AssetImage(imageAsset), fit: BoxFit.cover),
          // Vignette overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
          ),
          // Source icon on top
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.4,
              heightFactor: 0.4,
              child: SourceIcon(source: this.newsItem.source),
            ),
          ),
        ],
      ),
    );
  }
}
