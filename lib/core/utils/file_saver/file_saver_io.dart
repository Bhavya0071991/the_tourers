import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'file_saver_base.dart';

/// IO (mobile/desktop) implementation of [FileSaver] using `dart:io` and `path_provider`.
class FileSaverImpl implements FileSaver {
  @override
  Future<void> savePng(Uint8List bytes, String filename) async {
    try {
      Directory? targetDir;
      
      // On desktop platforms (like macOS), write directly to the Downloads directory
      if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
        targetDir = await getDownloadsDirectory();
      }
      
      // Fallback to Documents directory (standard on iOS and Android)
      targetDir ??= await getApplicationDocumentsDirectory();

      final File file = File('${targetDir.path}/$filename');
      await file.writeAsBytes(bytes);
      print('EPOD: Transparent artwork saved locally to: ${file.absolute.path}');
    } catch (e) {
      print('EPOD ERROR: Failed to write file locally: $e');
      rethrow;
    }
  }
}
