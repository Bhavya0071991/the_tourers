import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({required String email, required String password, required String name});
  Future<bool> loginWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
}
