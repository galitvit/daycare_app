import 'dart:io';
import 'dart:typed_data';

Future<String> saveDownloadedFile(Uint8List bytes, String fileName) async {
  final safeFileName = fileName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');

  Directory outputDirectory;
  if (Platform.isAndroid) {
    final downloadsDir = Directory('/storage/emulated/0/Download');
    outputDirectory = await downloadsDir.exists()
        ? downloadsDir
        : Directory.systemTemp;
  } else {
    outputDirectory = Directory.systemTemp;
  }

  if (!await outputDirectory.exists()) {
    await outputDirectory.create(recursive: true);
  }

  final file = File(
    '${outputDirectory.path}${Platform.pathSeparator}$safeFileName',
  );
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}