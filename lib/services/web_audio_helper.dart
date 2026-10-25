import 'dart:typed_data';
import 'web_audio_helper_stub.dart'
    if (dart.library.js_interop) 'web_audio_helper_web.dart' as helper;

class WebAudioHelper {
  static String createBlobUrl(Uint8List bytes, String mimeType) {
    return helper.createBlobUrl(bytes, mimeType);
  }

  static void revokeBlobUrl(String url) {
    helper.revokeBlobUrl(url);
  }
}
