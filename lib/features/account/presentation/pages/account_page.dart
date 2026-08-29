import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../order/providers/order_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/account_menu_tile.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../wishlist/providers/wishlist_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isAuthenticated = authState.value?.status == AuthStatus.authenticated;

    if (!isAuthenticated) {
      return _buildLoginPrompt(context, textColor, surfaceColor);
    }

    final orders = ref.watch(orderProvider).value ?? [];
    final ongoingCount = ref.watch(ongoingOrdersProvider).length;
    final wishlistCount = ref.watch(wishlistProvider).value?.length ?? 0;

    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  SafeArea(
              bottom: false,
              child: ProfileHeader(
                name: authState.value?.username ?? 'TOURER',
                email: authState.value?.email ?? '',
              ),
            ),

            const SizedBox(height: 8),

            // Quick stats
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  _StatCard(
                    label: 'ORDERS',
                    value: '${orders.length}',
                    textColor: textColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'ACTIVE',
                    value: '$ongoingCount',
                    textColor: textColor,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'WISHLIST',
                    value: '$wishlistCount',
                    textColor: textColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: textColor.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: AppText.spaceMono(
                      '/// ACCOUNT MENU',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.3),
                    ),
                  ),

                  AccountMenuTile(
                    icon: Icons.local_shipping_outlined,
                    title: 'My Orders',
                    subtitle: ongoingCount > 0
                        ? '$ongoingCount active order${ongoingCount > 1 ? "s" : ""}'
                        : 'View order history',
                    onTap: () => context.push(AppPaths.orders),
                  ),
                  AccountMenuTile(
                    icon: Icons.location_on_outlined,
                    title: 'Saved Addresses',
                    subtitle: 'Manage delivery addresses',
                    onTap: () => context.push(AppPaths.savedAddresses),
                  ),
                  AccountMenuTile(
                    icon: Icons.favorite_border,
                    title: 'Wishlist',
                    subtitle: 'Items you love',
                    onTap: () => context.push(AppPaths.wishlist),
                  ),
                  AccountMenuTile(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Saved AI Designs',
                    subtitle: 'Your custom creations',
                    onTap: () => context.push(AppPaths.savedDesigns),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // General section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: textColor.withValues(alpha: 0.1),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    child: AppText.spaceMono(
                      '/// GENERAL',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.3),
                    ),
                  ),

                  AccountMenuTile(
                    icon: Icons.headset_mic_outlined,
                    title: 'Help & Support',
                    subtitle: 'Contact us anytime',
                    onTap: () {},
                  ),
                  AccountMenuTile(
                    icon: Icons.info_outline,
                    title: 'About The Tourers',
                    subtitle: 'Our story',
                    onTap: () => context.push(AppPaths.about),
                  ),
                  AccountMenuTile(
                    icon: Icons.logout,
                    title: 'Logout',
                    iconColor: Colors.redAccent,
                    showDivider: false,
                    onTap: () => _showLogoutDialog(context, ref),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // App version
            AppText.spaceMono(
              'THE TOURERS. v1.0.0',
              fontSize: 9,
              color: textColor.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            AppText.spaceMono(
              '/// DESIGNED FOR TRAVELLERS',
              fontSize: 8,
              color: textColor.withValues(alpha: 0.15),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    ),
  ],
),
);
  }

  Widget _buildLoginPrompt(
    BuildContext context,
    Color textColor,
    Color surfaceColor,
  ) {
    return Scaffold(
      body: Column(
        children: [
          const CustomAppBar(),
          Expanded(
            child: SafeArea(
              top: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: textColor.withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 36,
                    color: textColor.withValues(alpha: 0.3),
                  ),
                ),
                const SizedBox(height: 32),
                AppText.bebas(
                  'IDENTITY REQUIRED',
                  fontSize: 32,
                  letterSpacing: 2,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                AppText.spaceMono(
                  'Login to access your account,\norders, and saved designs.',
                  fontSize: 11,
                  color: textColor.withValues(alpha: 0.4),
                  textAlign: TextAlign.center,
                  height: 1.6,
                ),
                const SizedBox(height: 32),
                BrutalistHoverWidget(
                  shadowColor: textColor.withValues(alpha: 0.2),
                  offset: const Offset(5, 5),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push(AppPaths.auth),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonAccent,
                        foregroundColor: AppTheme.pureBlack,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                          side: const BorderSide(color: AppTheme.pureBlack, width: 2),
                        ),
                      ),
                      child: AppText.bebas(
                        'LOGIN / REGISTER ↗',
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ],
),
);
}

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: surfaceColor,
            border: Border.all(color: textColor, width: 3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.bebas(
                'CONFIRM LOGOUT',
                fontSize: 24,
                color: textColor,
                letterSpacing: 1.5,
              ),
              const SizedBox(height: 12),
              AppText.spaceMono(
                'Are you sure you want to end\nyour session?',
                fontSize: 11,
                color: textColor.withValues(alpha: 0.5),
                textAlign: TextAlign.center,
                height: 1.5,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side: BorderSide(color: textColor, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(authProvider.notifier).logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: surfaceColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: Text(
                        'LOGOUT',
                        style: GoogleFonts.spaceMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color textColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: textColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.bebasNeue(fontSize: 24, color: textColor),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.spaceMono(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: textColor.withValues(alpha: 0.4),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
