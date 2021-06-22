import 'dart:io';

import 'package:dio/dio.dart';

/// Methods for downloading files
abstract class DownloadUtils {
  /// Download a file from an [url] to the location [downloadTo].
  static Future<bool> downloadFile({required String url, required File downloadTo, required void Function(double) onProgressChanged}) async {
    try {
      CancelToken cancelToken = CancelToken();
      await Dio().download(url, downloadTo.path, cancelToken: cancelToken, onReceiveProgress: (rec, total) {
        onProgressChanged((total > 0) ? (rec / total) : 0);
      });
    } catch (e) {
      // An error occurred
      print(e);
      return false;
    }
    // Download finished successfully
    return true;
  }
}
