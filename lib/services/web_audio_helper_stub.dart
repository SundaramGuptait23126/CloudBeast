import 'dart:typed_data';

String createBlobUrl(Uint8List bytes, String mimeType) {
  return Uri.dataFromBytes(bytes, mimeType: mimeType).toString();
}

void revokeBlobUrl(String url) {}
