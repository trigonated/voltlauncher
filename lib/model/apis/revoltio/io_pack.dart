import 'package:voltlauncher/model/objects/packs/pack.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';

/// A pack from the Re-volt IO API.
/// This corresponds to the API's corresponding json object.
class IOPack {
  final IOPackExtraData extraData;
  final String? description;
  final String? version;
  final String? checksum;
  final String url;

  IOPack({
    required this.extraData,
    required this.description,
    required this.version,
    required this.checksum,
    required this.url,
  });

  factory IOPack.fromJson({required PackRepository? source, required String name, required Map<String, dynamic> json, String? url}) {
    return IOPack(
      extraData: IOPackExtraData(
        source: source,
        name: name,
      ),
      description: json['description'],
      version: json['version']?.toString(),
      checksum: json['checksum'],
      url: json['url'] ?? url,
    );
  }

  Pack toPack() {
    return Pack(
      source: this.extraData.source,
      name: this.extraData.name,
      description: this.description,
      installedVersion: null,
      latestVersion: this.version,
      downloadUrl: this.url,
      checksum: this.checksum,
    );
  }
}

class IOPackExtraData {
  PackRepository? source; // Is nullable and non-final because when obtaining from the api there is no source yet
  final String name;

  IOPackExtraData({required this.source, required this.name});
}