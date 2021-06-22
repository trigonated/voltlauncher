import 'package:voltlauncher/model/apis/revoltio/io_pack.dart';
import 'package:voltlauncher/model/objects/sources/contentsource.dart';
import 'package:voltlauncher/model/objects/sources/packrepository.dart';

/// A pack repository from the Re-volt IO API.
/// This corresponds to the API's corresponding json object.
class IORepo {
  final IORepoExtraData extraData;
  final String name;
  final String? version;
  late List<IOPack> _packages;

  IORepo({
    required this.extraData,
    required this.name,
    required this.version,
    required List<IOPack> packages,
  }) {
    this._packages = packages;
  }

  factory IORepo.fromJson({required ContentSource source, required String url, required Map<String, dynamic> json}) {
    return IORepo(
      extraData: IORepoExtraData(
        source: source,
        url: url,
      ),
      name: json['name'],
      version: json['version']?.toString(),
      packages: json['packages']?.keys?.map<IOPack>((key) => IOPack.fromJson(source: null, name: key as String, json: json['packages'][key]))?.toList() ?? [],
    );
  }

  List<IOPack> packages({required PackRepository source}) {
    return this._packages.map((e) {
      e.extraData.source = source;
      return e;
    }).toList();
  }
}

class IORepoExtraData {
  final ContentSource source;
  final String url;

  IORepoExtraData({
    required this.source,
    required this.url,
  });
}
