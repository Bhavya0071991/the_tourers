import 'dart:typed_data';
import 'file_saver_base.dart';

/// Stub implementation of [FileSaver].
class FileSaverImpl implements FileSaver {
  @override
  Future<void> savePng(Uint8List bytes, String filename) {
    throw UnimplementedError('FileSaver is not implemented for this platform.');
  }
}
