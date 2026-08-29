import 'dart:typed_data';
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

/// Unified utility to save files across all Flutter targets (Web, iOS, Android, macOS).
class FileSaverService {
  static final _impl = FileSaverImpl();

  /// Saves the given [bytes] as a PNG file with name [filename].
  static Future<void> savePng(List<int> bytes, String filename) {
    final uint8Bytes = bytes is Uint8List ? bytes : Uint8List.fromList(bytes);
    return _impl.savePng(uint8Bytes, filename);
  }
}
