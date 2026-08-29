import 'package:dummy_epod/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:dummy_epod/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dummy_epod/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRemoteDataSourceImpl(supabase);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource);
});
