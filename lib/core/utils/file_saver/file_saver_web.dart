import 'dart:html' as html;
import 'dart:typed_data';
import 'file_saver_base.dart';

/// Web implementation of [FileSaver] using `dart:html`.
class FileSaverImpl implements FileSaver {
  @override
  Future<void> savePng(Uint8List bytes, String filename) async {
    final blob = html.Blob([bytes], 'image/png');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..style.display = 'none';
    
    html.document.body?.children.add(anchor);
    anchor.click();
    
    // Clean up
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
