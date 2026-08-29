import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/admin_sidebar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';

class AdminLayout extends ConsumerWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          const AdminSidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: textColor, width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: AppText.spaceMono(
                          AppStrings.adminTitle,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          NotificationBell(color: textColor),
                          const SizedBox(width: 24),
                          Flexible(
                            child: InkWell(
                              onTap: () async {
                                final shouldLogout = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Theme.of(context).colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                      side: BorderSide(color: textColor, width: 2),
                                    ),
                                    title: AppText.bebas('CONFIRM LOGOUT', fontSize: 24, color: textColor),
                                    content: AppText.spaceMono('Are you sure you want to exit the admin panel?', fontSize: 14, color: textColor),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: AppText.spaceMono('CANCEL', color: textColor, fontWeight: FontWeight.bold),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: textColor,
                                          foregroundColor: Theme.of(context).colorScheme.surface,
                                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                        ),
                                        onPressed: () => Navigator.of(context).pop(true),
                                        child: AppText.spaceMono('LOGOUT', fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldLogout == true) {
                                  await ref.read(authProvider.notifier).logout();
                                  if (context.mounted) {
                                    context.go(AppPaths.adminLogin);
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: textColor, width: 2),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.exit_to_app,
                                      color: textColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: AppText.spaceMono(
                                        AppStrings.adminExit,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        maxLines: 1,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Page Content
                Expanded(
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
