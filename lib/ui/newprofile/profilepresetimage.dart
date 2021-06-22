import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/model/objects/profiles/profilepreset.dart';
import 'package:voltlauncher/ui/misc/profileicon.dart';
import 'package:voltlauncher/ui/misc/sourceicon.dart';

/// Image widget that displays the image of a [ProfilePreset].
class ProfilePresetImage extends StatelessWidget {
  final ProfilePreset preset;

  ProfilePresetImage({
    required this.preset,
  });

  @override
  Widget build(BuildContext context) {
    if (this.preset.imageUrl != null) {
      // Load the preset's image. This image can be one of the default ones or a custom image.
      String? defaultAssetName = Assets.graphics.presets.fromDefaultUrl(this.preset.imageUrl!);
      if (defaultAssetName != null) {
        // The url is a default asset
        return AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: Image(image: AssetImage(defaultAssetName), fit: BoxFit.cover),
        );
      } else {
        // The url is a remote image (or invalid default asset)
        return AspectRatio(
          aspectRatio: 16.0 / 9.0,
          child: FadeInImage.assetNetwork(
            placeholder: Assets.graphics.presets.preset_loading,
            image: this.preset.imageUrl!,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      // Event doesn't have an image url
      return _buildFallbackImage(context);
    }
  }

  // Build a fallback image.
  Widget _buildFallbackImage(BuildContext context) {
    String backgroundImageAsset = Assets.graphics.presets.preset_default;
    Widget? icon;
    if (this.preset.source != null) {
      if (this.preset.source!.sourceProfileId != null) {
        // Clone profile
        backgroundImageAsset = Assets.graphics.presets.preset_clone;
        icon = ProfileIcon(profileId: this.preset.source!.sourceProfileId, size: 80);
      } else {
        // Other (show the source's icon)
        icon = SourceIcon(source: this.preset.source!, size: 80);
      }
    } else if (this.preset.isEmpty) {
      // Create empty profile
      backgroundImageAsset = Assets.graphics.presets.preset_empty;
      icon = Icon(Icons.fact_check, size: 80, color: Colors.white);
    }
    return AspectRatio(
      aspectRatio: 16.0 / 9.0,
      child: Stack(
        children: [
          // Image
          Image(image: AssetImage(backgroundImageAsset), fit: BoxFit.cover),
          // Vignette overlay
          (icon != null)
              ? Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1,
                      colors: [Colors.black, Colors.transparent],
                    ),
                  ),
                )
              : SizedBox.shrink(),
          // Icon on top
          (icon != null)
              ? Center(
                  child: icon,
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
