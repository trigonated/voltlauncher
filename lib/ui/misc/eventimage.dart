import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/misc/iterable_extensions.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/model/objects/events/event.dart';
import 'package:voltlauncher/ui/misc/sourceicon.dart';

/// Image widget that displays the image of an [Event].
class EventImage extends StatelessWidget {
  final Event event;

  EventImage({
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    if (this.event.imageUrl != null) {
      // Load the event's image
      return AspectRatio(
        aspectRatio: 16.0 / 9.0,
        child: FadeInImage.assetNetwork(
          placeholder: Assets.graphics.events.event_loading,
          image: this.event.imageUrl!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Event doesn't have an image url
      return _buildFallbackImage(context);
    }
  }

  // Build a fallback image based on the event's tracks.
  Widget _buildFallbackImage(BuildContext context) {
    final String imageAsset = _getEventImageAsset() ?? Assets.graphics.events.event_default(this.event.title.length + this.event.date.millisecondsSinceEpoch);
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
              child: SourceIcon(source: this.event.source),
            ),
          ),
        ],
      ),
    );
  }

  /// Get an image asset based on the event's tracks.
  String? _getEventImageAsset() {
    final List<String> imagesPool = this.event.trackList?.mapNotNull((e) => Assets.graphics.events.forTrackName(e.name)).toList() ?? [];
    if (imagesPool.isNotEmpty) {
      // Pick a semi-random image from the pool of tracks
      return imagesPool[this.event.date.millisecondsSinceEpoch % imagesPool.length];
    } else {
      // The event doesn't have any stock tracks
      return null;
    }
  }
}
