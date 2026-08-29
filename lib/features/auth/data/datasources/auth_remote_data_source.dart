import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
  });
  Future<bool> loginWithGoogle();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty ||
        !email.contains('@') ||
        password.trim().length < 6) {
      throw Exception('Invalid credentials');
    }

    final response = await supabaseClient.auth.signInWithPassword(email: email, password: password);
    final user = response.user;
    if (user == null) {
      throw Exception('Login failed');
    }

    final username = user.userMetadata?['full_name'] as String? ?? email.split('@').first.toUpperCase();

    String role = 'user';
    try {
      final profile = await supabaseClient.from('profiles').select('role').eq('id', user.id).maybeSingle();
      if (profile != null && profile['role'] != null) {
        role = profile['role'] as String;
      }
    } catch (_) {}

    return UserEntity(
      id: user.id,
      email: user.email ?? email,
      username: username,
      role: role,
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.trim().isEmpty ||
        !email.contains('@') ||
        password.trim().length < 6 ||
        name.trim().isEmpty) {
      throw Exception('Please fill all fields correctly');
    }

    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name.trim().toUpperCase()},
      emailRedirectTo: kIsWeb ? Uri.base.origin : null,
    );

    final user = response.user;
    if (user == null) {
      throw Exception('Registration failed');
    }

    // Role will typically be 'user' by default on signup, but checking for safety
    String role = 'user';
    try {
      final profile = await supabaseClient.from('profiles').select('role').eq('id', user.id).maybeSingle();
      if (profile != null && profile['role'] != null) {
        role = profile['role'] as String;
      }
    } catch (_) {}

    return UserEntity(
      id: user.id,
      email: user.email ?? email,
      username: name.trim().toUpperCase(),
      role: role,
    );
  }

  @override
  Future<bool> loginWithGoogle() async {
    try {
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? Uri.base.origin : null,
        queryParams: {'prompt': 'select_account'},
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw Exception('Invalid email address');
    }
    await supabaseClient.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: kIsWeb ? Uri.base.origin : null,
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    if (newPassword.trim().length < 6) {
      throw Exception('Password must be at least 6 characters long');
    }
    await supabaseClient.auth.updateUser(
      UserAttributes(password: newPassword.trim()),
    );
  }
}
