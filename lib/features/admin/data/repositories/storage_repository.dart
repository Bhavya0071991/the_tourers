import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final SupabaseClient _supabaseClient;

  StorageRepository(this._supabaseClient);

  Future<String> uploadBinary(String bucketName, String fileName, Uint8List bytes) async {
    await _supabaseClient.storage.from(bucketName).uploadBinary(fileName, bytes);
    return _supabaseClient.storage.from(bucketName).getPublicUrl(fileName);
  }
}
