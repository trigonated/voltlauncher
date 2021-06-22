import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:voltlauncher/main.dart';
import 'package:voltlauncher/misc/assets.dart';
import 'package:voltlauncher/misc/image_cropper.dart';
import 'package:voltlauncher/misc/localdirectories.dart';
import 'package:voltlauncher/misc/url_opener.dart';
import 'package:voltlauncher/model/objects/events/event_car.dart';
import 'package:voltlauncher/model/objects/local/local_car.dart';
import 'package:voltlauncher/ui/misc/itemcontainer.dart';

/// Item that represents an event's carlist item.
class ProfileEventsCarItem extends StatefulWidget {
  final EventCar car;

  ProfileEventsCarItem({Key? key, required this.car}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEventsCarItemState();
}

class _ProfileEventsCarItemState extends State<ProfileEventsCarItem> {
  late Future<LocalCar?>? _localCar;
  Future<ImageProvider?>? _imageProvider;

  @override
  void initState() {
    super.initState();

    _localCar = (widget.car.isCar) ? repository.local.fetchCar(name: widget.car.name) : null;
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
              child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Text(widget.car.displayName, style: TextStyle(fontSize: 14)),
              ),
            ),
            // Car box
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
                child: FutureBuilder<LocalCar?>(
                  future: _localCar,
                  builder: (context, snapshot) {
                    LocalCar? localCar = snapshot.data;
                    if ((_imageProvider == null) && (localCar != null)) {
                      _imageProvider = _getImageProvider(localCar);
                    }
                    return FutureBuilder<ImageProvider?>(
                      future: _imageProvider,
                      builder: (context, snapshot) {
                        return Image(
                          image: snapshot.data ?? _getDefaultImageProvider(localCar),
                          fit: BoxFit.cover,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      onTap: (widget.car.url != null) ? () => UrlOpener.openUrl(widget.car.url!) : null,
    );
  }

  /// Get the [ImageProvider] for the car. The image can be either a car, a class or the default car image.
  Future<ImageProvider> _getImageProvider(LocalCar? car) async {
    if (car != null) {
      if (car.isStock) {
        // It's a stock car
        StockCarCarBoxInfo carBoxInfo = LocalDirectories.appData.installs.currentInstall.packs.rvglAssets.stockCarCarbox(car.id);
        Uint8List imageBytes = await ImageCropper.cropFileImageThird(carBoxInfo.file, carBoxInfo.row, carBoxInfo.col);
        return MemoryImage(imageBytes);
      } else if (car.boxArt?.existsSync() == true) {
        // It's not a stock car, but the car's box  was found.
        return FileImage(car.boxArt!);
      }
    }
    // It's either a class or a car that doesn't have a car box.
    return AssetImage((widget.car.type == EventCarType.carClass) ? Assets.graphics.class_default : Assets.graphics.car_default);
  }

  /// Get a default image.
  ImageProvider _getDefaultImageProvider(LocalCar? car) {
    return AssetImage((widget.car.type == EventCarType.carClass) ? Assets.graphics.class_default : Assets.graphics.car_default);
  }
}
