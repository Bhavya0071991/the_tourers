import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../data/repositories/storage_repository.dart';

final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return StorageRepository(supabaseClient);
});
