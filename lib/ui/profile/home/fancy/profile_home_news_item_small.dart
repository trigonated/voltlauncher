import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:voltlauncher/misc/stringutils.dart';
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';
import 'package:voltlauncher/ui/misc/newsimage.dart';

/// A "small" (to be used on a list) news item.
class ProfileHomeNewsItemSmall extends StatefulWidget {
  final NewsItem newsItem;
  final void Function(NewsItem newsItem) onTap;

  ProfileHomeNewsItemSmall({Key? key, required this.newsItem, required this.onTap}) : super(key: key);

  @override
  _ProfileHomeNewsItemSmallState createState() => _ProfileHomeNewsItemSmallState();
}

class _ProfileHomeNewsItemSmallState extends State<ProfileHomeNewsItemSmall> {
  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      onTap: () => widget.onTap.call(widget.newsItem),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image
        NewsImage(newsItem: widget.newsItem),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  child: Row(
                    children: [
                      // Date
                      Expanded(
                        child: Text(
                          StringUtils.generatePrettyDate(widget.newsItem.date).toUpperCase(),
                          style: TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Title
                Text(
                  widget.newsItem.title,
                  maxLines: 2,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
