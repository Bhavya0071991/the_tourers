import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'auth_dependency_providers.dart';
import '../../../core/network/supabase_client.dart';

enum AuthStatus { authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? id;
  final String? email;
  final String? username;
  final String role;

  const AuthState({
    required this.status,
    this.id,
    this.email,
    this.username,
    this.role = 'user',
  });

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      id = null,
      email = null,
      username = null,
      role = 'user';

  const AuthState.authenticated({
    required this.id,
    required this.email,
    required this.username,
    this.role = 'user',
  }) : status = AuthStatus.authenticated;

  AuthState copyWith({
    AuthStatus? status,
    String? id,
    String? email,
    String? username,
    String? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  StreamSubscription? _authSubscription;

  @override
  FutureOr<AuthState> build() async {
    final supabase = ref.watch(supabaseClientProvider);
    
    // Helper to fetch role
    Future<String> fetchRole(String userId) async {
      try {
        final profile = await supabase.from('profiles').select('role').eq('id', userId).maybeSingle();
        if (profile != null && profile['role'] != null) {
          return profile['role'] as String;
        }
      } catch (_) {}
      return 'user';
    }

    // Listen to Supabase auth state changes
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      
      if (data.event == AuthChangeEvent.passwordRecovery) {
        ref.read(requiresPasswordResetProvider.notifier).state = true;
      }

      if (session != null) {
        final role = await fetchRole(session.user.id);
        state = AsyncData(
          AuthState.authenticated(
            id: session.user.id,
            email: session.user.email,
            username:
                session.user.userMetadata?['full_name'] ??
                session.user.email?.split('@').first ??
                'User',
            role: role,
          ),
        );
      } else {
        state = const AsyncData(AuthState.unauthenticated());
      }
    });

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    final session = supabase.auth.currentSession;
    if (session != null) {
      final role = await fetchRole(session.user.id);
      return AuthState.authenticated(
        id: session.user.id,
        email: session.user.email,
        username:
            session.user.userMetadata?['full_name'] ??
            session.user.email?.split('@').first ??
            'User',
        role: role,
      );
    }
    return const AuthState.unauthenticated();
  }

  Future<String?> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(email: email, password: password);

      state = AsyncData(
        AuthState.authenticated(
          id: user.id,
          email: user.email, 
          username: user.username,
          role: user.role,
        ),
      );
      return null;
    } catch (e) {
      state = const AsyncData(AuthState.unauthenticated());
      return _parseAuthError(e);
    }
  }

  Future<String?> register(String email, String password, String name) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.register(email: email, password: password, name: name);

      // Do not auto-login. Wait for email verification.
      state = const AsyncData(AuthState.unauthenticated());
      return null;
    } catch (e) {
      state = const AsyncData(AuthState.unauthenticated());
      return _parseAuthError(e);
    }
  }

  Future<String?> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final success = await repository.loginWithGoogle();
      if (!success) return 'Google login failed';
      return null;
    } catch (e) {
      state = const AsyncData(AuthState.unauthenticated());
      return _parseAuthError(e);
    }
  }

  Future<String?> resetPassword(String email) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.resetPassword(email);
      state = const AsyncData(AuthState.unauthenticated());
      return null;
    } catch (e) {
      state = const AsyncData(AuthState.unauthenticated());
      return _parseAuthError(e);
    }
  }

  Future<String?> updatePassword(String newPassword) async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.updatePassword(newPassword);
      // After success, clear the flag
      ref.read(requiresPasswordResetProvider.notifier).state = false;
      
      // Update session state
      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session != null) {
        state = AsyncData(
          AuthState.authenticated(
            id: session.user.id,
            email: session.user.email,
            username: session.user.userMetadata?['full_name'] ?? session.user.email?.split('@').first ?? 'User',
            role: state.value?.role ?? 'user',
          ),
        );
      }
      return null;
    } catch (e) {
      // Revert loading state by reloading the current state
      final supabase = ref.read(supabaseClientProvider);
      final session = supabase.auth.currentSession;
      if (session != null) {
        state = AsyncData(
          AuthState.authenticated(
            id: session.user.id,
            email: session.user.email,
            username: session.user.userMetadata?['full_name'] ?? session.user.email?.split('@').first ?? 'User',
            role: state.value?.role ?? 'user',
          ),
        );
      } else {
        state = const AsyncData(AuthState.unauthenticated());
      }
      return _parseAuthError(e);
    }
  }

  String _parseAuthError(dynamic e) {
    if (e is AuthException) {
      // Supabase sometimes returns a JSON string in the message for fetch errors
      if (e.message.contains('"message":')) {
        try {
          // Very basic parsing to get the inner message if it's JSON
          final parts = e.message.split('"message":"');
          if (parts.length > 1) {
            return parts[1].split('"').first;
          }
        } catch (_) {}
      }
      return e.message;
    }

    final errorString = e.toString();
    if (errorString.startsWith('Exception: ')) {
      return errorString.substring(11);
    }
    return errorString;
  }

  Future<void> logout() async {
    await ref.read(supabaseClientProvider).auth.signOut();
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// StateProvider for managing the login/register mode toggle in the UI
final authLoginModeProvider = StateProvider.autoDispose<bool>((ref) => true);

// StateProvider to track if user is in password recovery mode
final requiresPasswordResetProvider = StateProvider<bool>((ref) => false);
