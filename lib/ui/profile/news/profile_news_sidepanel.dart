import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:voltlauncher/model/objects/news/newsitem.dart';
import 'package:voltlauncher/misc/url_opener.dart';
import 'package:voltlauncher/ui/misc/newsimage.dart';
import 'package:voltlauncher/ui/misc/sourceindicator.dart';

class ProfileNewsSidePanel extends StatefulWidget {
  final NewsItem? newsItem;

  ProfileNewsSidePanel({Key? key, required this.newsItem}) : super(key: key);

  @override
  _ProfileNewsSidePanelState createState() => _ProfileNewsSidePanelState();
}

class _ProfileNewsSidePanelState extends State<ProfileNewsSidePanel> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newsItem == null) return Center(child: Text("Select a news item on the left"));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          foregroundDecoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
          ),
          child: NewsImage(newsItem: widget.newsItem!),
        ),
        Expanded(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              // Content provider
              _buildContentProviderRow(context),
              SizedBox(height: 8),
              // Tags
              (widget.newsItem!.tags.isNotEmpty) ? _buildTagsRow(context) : SizedBox.shrink(),
              // Title
              _buildTitleRow(context),
              // Time
              SizedBox(height: 16),
              _buildTimeRow(context),
              // Description
              SizedBox(height: 16),
              _buildDescriptionRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentProviderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SourceIndicator(source: widget.newsItem!.source),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            child: (widget.newsItem!.url != null) ? _buildContentProviderRowOptionsButton(context) : SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildContentProviderRowOptionsButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.open_in_browser),
      constraints: BoxConstraints(minWidth: 24, minHeight: 24),
      padding: EdgeInsetsDirectional.only(),
      iconSize: 16,
      onPressed: () => UrlOpener.openUrl(widget.newsItem!.url!),
    );
  }

  Widget _buildTagsRow(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.newsItem!.tags
          .map((e) => Chip(
                label: Text(toBeginningOfSentenceCase(e)!),
              ))
          .toList(),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Text(
      widget.newsItem!.title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTimeRow(BuildContext context) {
    String time = DateFormat.yMMMMd().add_Hm().format(widget.newsItem!.date);
    String prettyTimeAgo = timeago.format(widget.newsItem!.date);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("On: ", style: TextStyle(color: Colors.white54, fontSize: 14)),
        Text("$time ($prettyTimeAgo)", style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildDescriptionRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Description", style: TextStyle(color: Colors.white54, fontSize: 14)),
        MarkdownBody(data: widget.newsItem!.description ?? "No description"),
      ],
    );
  }
}
