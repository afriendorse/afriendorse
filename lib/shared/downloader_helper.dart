import 'package:flutter_downloader/flutter_downloader.dart';

class DownloaderHelper {
  static bool _initialized = false;

  static Future<void> initialize({
    bool debug = false,
    bool ignoreSsl = false,
  }) async {
    if (!_initialized) {
      await FlutterDownloader.initialize(debug: debug, ignoreSsl: ignoreSsl);
      _initialized = true;
    }
  }
}
