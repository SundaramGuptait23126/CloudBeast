import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

String createBlobUrl(Uint8List bytes, String mimeType) {
  final jsArray = [bytes.toJS].toJS;
  final blob = web.Blob(jsArray, web.BlobPropertyBag(type: mimeType));
  return web.URL.createObjectURL(blob);
}

void revokeBlobUrl(String url) {
  web.URL.revokeObjectURL(url);
}
