import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../../models/notification_model.dart';

class NotificationRepository {
  final SupabaseClient _supabase;

  NotificationRepository(this._supabase);

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).toIso8601String();

    // Lazy cleanup: Delete notifications older than 7 days for this user
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .lt('created_at', sevenDaysAgo);
    } catch (e) {
      // Ignore cleanup errors
    }

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .gte('created_at', sevenDaysAgo)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List<dynamic>)
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> insertNotification({
    required String userId,
    required String title,
    required String message,
    required String type,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'title': title,
      'message': message,
      'type': type,
      'is_read': false,
    });
  }

  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NotificationRepository(supabase);
});
