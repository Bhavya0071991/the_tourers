import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/collection_model.dart';

final collectionsProvider = FutureProvider<List<CollectionModel>>((ref) async {
  final repository = ref.watch(collectionRepositoryProvider);
  return repository.fetchCollections();
});

final collectionRepositoryProvider = Provider<CollectionRepository>((ref) {
  return CollectionRepository(Supabase.instance.client);
});

class CollectionRepository {
  final SupabaseClient _supabase;

  CollectionRepository(this._supabase);

  Future<List<CollectionModel>> fetchCollections() async {
    try {
      final response = await _supabase
          .from('shop_collections')
          .select()
          .order('sort_order', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CollectionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error fetching collections: $e\n$stack');
      }
      rethrow;
    }
  }

  Future<void> addCollection(CollectionModel collection) async {
    await _supabase.from('shop_collections').insert(collection.toJson());
  }

  Future<void> updateCollection(CollectionModel collection) async {
    await _supabase
        .from('shop_collections')
        .update(collection.toJson())
        .eq('id', collection.id);
  }

  Future<void> deleteCollection(String id) async {
    await _supabase.from('shop_collections').delete().eq('id', id);
  }

  Future<String> uploadCollectionImage(
      String fileName, dynamic fileOrBytes) async {
    final bucket = _supabase.storage.from('collections');
    final String path = 'collections/$fileName';

    if (kIsWeb) {
      await bucket.uploadBinary(
        path,
        fileOrBytes as Uint8List,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
    } else {
      await bucket.upload(
        path,
        fileOrBytes as File,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
      );
    }

    return bucket.getPublicUrl(path);
  }
}
