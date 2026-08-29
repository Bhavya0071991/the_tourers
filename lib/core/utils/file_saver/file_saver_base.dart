import 'dart:typed_data';

/// Abstract class defining the file saving interface for multi-platform support.
abstract class FileSaver {
  /// Saves PNG bytes as a file with the given filename.
  Future<void> savePng(Uint8List bytes, String filename);
}
