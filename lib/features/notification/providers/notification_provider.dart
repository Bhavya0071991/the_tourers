import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/repositories/notification_repository.dart';
import '../models/notification_model.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  RealtimeChannel? _subscription;
  String? _listeningUserId;

  @override
  FutureOr<List<NotificationModel>> build() async {
    ref.onDispose(() {
      _subscription?.unsubscribe();
    });

    final authState = ref.watch(authProvider).value;

    if (authState == null || authState.status != AuthStatus.authenticated) {
      _subscription?.unsubscribe();
      _subscription = null;
      _listeningUserId = null;
      return [];
    }

    // Determine which ID to listen to
    final isAdmin =
        authState.role == 'admin' || authState.role == 'super_admin';
    _listeningUserId = isAdmin ? 'ADMIN' : authState.id;

    if (_listeningUserId == null) return [];

    _setupRealtime(_listeningUserId!);
    return _fetchNotifications(_listeningUserId!);
  }

  void _setupRealtime(String userId) {
    _subscription?.unsubscribe();

    _subscription = ref
        .read(supabaseClientProvider)
        .channel('public:notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            final newNotifications = await _fetchNotifications(userId);
            state = AsyncData(newNotifications);
          },
        )
        .subscribe();
  }

  Future<List<NotificationModel>> _fetchNotifications(String userId) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      return await repository.fetchNotifications(userId);
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAsRead(notificationId);

      // Optimistic update
      if (state.value != null) {
        state = AsyncData(
          state.value!.map((n) {
            return n.id == notificationId ? n.copyWith(isRead: true) : n;
          }).toList(),
        );
      }
    } catch (e) {
      print('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    if (_listeningUserId == null) return;
    try {
      final repository = ref.read(notificationRepositoryProvider);
      await repository.markAllAsRead(_listeningUserId!);

      // Optimistic update
      if (state.value != null) {
        state = AsyncData(
          state.value!.map((n) => n.copyWith(isRead: true)).toList(),
        );
      }
    } catch (e) {
      print('Failed to mark all as read: $e');
    }
  }
}

final notificationProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationModel>>(
      NotificationNotifier.new,
    );

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationProvider).value ?? [];
  return notifications.where((n) => !n.isRead).length;
});
