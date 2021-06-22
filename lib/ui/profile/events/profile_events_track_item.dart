import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/model/objects/events/event_track.dart';
import 'package:voltlauncher/model/objects/local/local_track.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';

/// Item that represents an event's track list item.
class ProfileEventsTrackItem extends StatefulWidget {
  final EventTrack track;

  ProfileEventsTrackItem({Key? key, required this.track}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEventsTrackItemState();
}

class _ProfileEventsTrackItemState extends State<ProfileEventsTrackItem> {
  Future<LocalTrack?> get _localTrack => repository.local.fetchTrack(name: widget.track.name);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ItemContainer(
      child: Container(
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name
                    Tooltip(
                      message: widget.track.displayName,
                      child: Text(widget.track.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14)),
                    ),
                    // Extra info (laps, duration, pickups, etc)
                    (_getExtraInfoText().isNotEmpty) ? Text(_getExtraInfoText(), style: TextStyle(color: Colors.white54, fontSize: 12)) : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            // Image
            AspectRatio(
              aspectRatio: 21.0 / 9.0,
              child: ShaderMask(
                shaderCallback: (rect) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.transparent, Colors.black],
                  ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                },
                blendMode: BlendMode.dstIn,
                child: FutureBuilder<LocalTrack?>(
                  future: _localTrack,
                  builder: (context, snapshot) {
                    return Image(
                      image: _getImageProvider(snapshot.data),
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create the extra info string. This is a string describing the number
  /// of lap or the duration of the track, as well and whether pickups are active or not.
  String _getExtraInfoText() {
    String extraInfo = "";
    if (widget.track.laps != null) {
      // Laps
      extraInfo += widget.track.laps.toString() + ((widget.track.laps == 1) ? " lap" : " laps");
    } else if (widget.track.minutes != null) {
      // Minutes
      extraInfo += widget.track.minutes.toString() + ((widget.track.minutes == 1) ? " minute" : " minutes");
    }
    if (widget.track.pickups != null) {
      // Pickups
      extraInfo += ((extraInfo.isNotEmpty) ? ", " : "") + ((widget.track.pickups!) ? "with pickups" : "without pickups");
    }
    return extraInfo;
  }

  /// Get the [ImageProvider] for the track.
  ImageProvider _getImageProvider(LocalTrack? track) {
    if (track != null) {
      if (track.image?.existsSync() == true) return FileImage(track.image!);
    }
    return AssetImage(Assets.graphics.track_default);
  }
}
