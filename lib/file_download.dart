import 'dart:typed_data';

import 'file_download_stub.dart'
    if (dart.library.html) 'file_download_web.dart'
    if (dart.library.io) 'file_download_io.dart' as impl;

Future<String> saveDownloadedFile(Uint8List bytes, String fileName) {
  return impl.saveDownloadedFile(bytes, fileName);
}