import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/router/app_paths.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/notification_provider.dart';

String _formatTimeAgo(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inDays > 8) {
    return '${date.day}/${date.month}/${date.year}';
  } else if ((difference.inDays / 7).floor() >= 1) {
    return '1 week ago';
  } else if (difference.inDays >= 2) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays >= 1) {
    return '1 day ago';
  } else if (difference.inHours >= 2) {
    return '${difference.inHours} hours ago';
  } else if (difference.inHours >= 1) {
    return '1 hour ago';
  } else if (difference.inMinutes >= 2) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inMinutes >= 1) {
    return '1 minute ago';
  } else if (difference.inSeconds >= 3) {
    return '${difference.inSeconds} seconds ago';
  } else {
    return 'Just now';
  }
}

class NotificationBell extends ConsumerStatefulWidget {
  final Color color;
  const NotificationBell({super.key, required this.color});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  void _showNotificationsMenu(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              top: 70, // Below app bar
              right: 24, // Margin from right
              child: Material(
                color: Colors.transparent,
                child: _NotificationPanel(color: widget.color),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showNotificationsMenu(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Base Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent, width: 1.5),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: widget.color,
                size: 28,
              ),
            ),

            // Badge
            if (unreadCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.neonAccent,
                    border: Border.all(color: AppTheme.pureBlack, width: 1.5),
                  ),
                  child: AppText.spaceMono(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.pureBlack,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationPanel extends ConsumerWidget {
  final Color color;
  const _NotificationPanel({required this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationProvider);

    return BrutalistHoverWidget(
      offset: const Offset(6, 6),
      shadowColor: color.withValues(alpha: 0.2),
      child: Container(
        width: 380,
        height: 500,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: color, width: 2)),
                color: AppTheme.neonAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.bebas(
                    'NOTIFICATIONS',
                    fontSize: 24,
                    color: AppTheme.pureBlack,
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(notificationProvider.notifier).markAllAsRead();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      backgroundColor: AppTheme.pureBlack,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: AppText.spaceMono(
                      'MARK ALL READ',
                      fontSize: 10,
                      color: AppTheme.neonAccent,
                    ),
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return Center(
                      child: AppText.spaceMono(
                        'No notifications yet.',
                        color: color.withValues(alpha: 0.5),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: color.withValues(alpha: 0.2), height: 1),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return InkWell(
                        onTap: () {
                          // Mark as read
                          if (!n.isRead) {
                            ref
                                .read(notificationProvider.notifier)
                                .markAsRead(n.id);
                          }

                          // Close dialog
                          Navigator.of(context).pop();

                          // Navigate to appropriate Orders page
                          final authState = ref.read(authProvider).value;
                          final isAdmin =
                              authState?.role == 'admin' ||
                              authState?.role == 'super_admin';

                          if (isAdmin) {
                            context.go(AppPaths.adminOrders);
                          } else {
                            context.go(AppPaths.orders);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: n.isRead
                              ? Colors.transparent
                              : color.withValues(alpha: 0.05),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Icon
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).scaffoldBackgroundColor,
                                  border: Border.all(color: color),
                                ),
                                child: Icon(
                                  _getIconForType(n.type),
                                  color: color,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: AppText.spaceMono(
                                            n.title,
                                            fontWeight: FontWeight.bold,
                                            color: color,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (!n.isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            color: AppTheme.neonAccent,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    AppText.spaceMono(
                                      n.message,
                                      color: color.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    AppText.spaceMono(
                                      _formatTimeAgo(n.createdAt),
                                      color: color.withValues(alpha: 0.4),
                                      fontSize: 9,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    Center(child: CircularProgressIndicator(color: color)),
                error: (err, stack) => Center(
                  child: AppText.spaceMono(
                    'Error loading notifications',
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'order_created':
        return Icons.shopping_cart_checkout;
      case 'status_update':
        return Icons.local_shipping;
      case 'payment_failed':
        return Icons.error_outline;
      default:
        return Icons.notifications;
    }
  }
}
