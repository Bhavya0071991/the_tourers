import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login({required String email, required String password}) {
    return remoteDataSource.login(email: email, password: password);
  }

  @override
  Future<UserEntity> register({required String email, required String password, required String name}) {
    return remoteDataSource.register(email: email, password: password, name: name);
  }

  @override
  Future<bool> loginWithGoogle() {
    return remoteDataSource.loginWithGoogle();
  }

  @override
  Future<void> logout() async {
    // Simulate network logout if needed
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> resetPassword(String email) {
    return remoteDataSource.resetPassword(email);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    return remoteDataSource.updatePassword(newPassword);
  }
}
