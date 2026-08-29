import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../notification/presentation/widgets/notification_bell.dart';
import '../../../../core/widgets/brand_logo_icon.dart';

class CustomAppBar extends ConsumerWidget {
  final bool isTransparent;

  const CustomAppBar({super.key, this.isTransparent = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final textColor = Theme.of(context).colorScheme.onSurface;

    final cartCount = ref.watch(cartItemCountProvider);
    final authStatus = ref.watch(
      authProvider.select(
        (state) => state.value?.status ?? AuthStatus.unauthenticated,
      ),
    );
    final authUsername = ref.watch(
      authProvider.select((state) => state.value?.username),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64.0 : 16.0,
        vertical: isDesktop ? 24.0 : 16.0,
      ),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Brutalist Logo with Icon
          GestureDetector(
            onTap: () => context.go(AppPaths.home),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandLogoIcon(size: isDesktop ? 36 : 30, color: textColor),
                  const SizedBox(width: 10),
                  AppText.bebas(
                    AppStrings.appName,
                    fontSize: isDesktop ? 36 : 24,
                    letterSpacing: 1.0,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ),

          // Center/Right: Navigation Links
          if (isDesktop)
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildAnimatedNavLink(
                      AppStrings.navNewArrival,
                      textColor,
                      onTap: () => context.go(AppPaths.home),
                    ),
                    Positioned(
                      bottom: -8,
                      right: 8,
                      child:
                          AppText.spaceMono(
                                'NEW ✨',
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .fade(duration: 800.ms, begin: 0.3, end: 1.0),
                    ),
                  ],
                ),
                const SizedBox(width: 32),
                _buildAnimatedNavLink(
                  AppStrings.navMens,
                  textColor,
                  onTap: () => context.go(AppPaths.categoryId('mens')),
                ),
                const SizedBox(width: 32),
                _buildAnimatedNavLink(
                  AppStrings.navWomens,
                  textColor,
                  onTap: () => context.go(AppPaths.categoryId('womens')),
                ),
                const SizedBox(width: 32),

                // _buildAnimatedNavLink(
                //   'PORTRAITS',
                //   textColor,
                //   onTap: () => context.go(AppPaths.portraits),
                // ),
                // const SizedBox(width: 32),
                // _buildAnimatedNavLink(
                //   'AI LAB',
                //   textColor,
                //   onTap: () => context.go(AppPaths.generator),
                // ),
                // const SizedBox(width: 32),
                AppText.spaceMono('|', color: textColor, fontSize: 16),
                const SizedBox(width: 32),
                NotificationBell(color: textColor),
                const SizedBox(width: 32),
                _buildCartIcon(context, textColor, cartCount),
                const SizedBox(width: 32),
                _buildAuthIndicator(
                  context,
                  textColor,
                  authStatus,
                  authUsername,
                ),
              ],
            ),

          if (!isDesktop)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                NotificationBell(color: textColor),
                const SizedBox(width: 8),
                _buildCartIcon(context, textColor, cartCount),
                const SizedBox(width: 4),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(4),
                    onTap: () {
                      _showMobileMenu(
                        context,
                        textColor,
                        cartCount,
                        authStatus,
                        authUsername,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.menu, color: textColor, size: 28),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showMobileMenu(
    BuildContext context,
    Color textColor,
    int cartCount,
    AuthStatus authStatus,
    String? authUsername,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close menu',
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: AppTheme.pureBlack,
              child: SafeArea(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.78,
                  height: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: AppTheme.neonAccent.withValues(alpha: 0.4),
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 12, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              AppText.spaceMono(
                                '/// MENU',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neonAccent,
                                letterSpacing: 2.0,
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Separator
                        Container(
                          height: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          color: Colors.white.withValues(alpha: 0.06),
                        ),

                        // Menu items
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _buildMobileMenuItem(
                                      context,
                                      0,
                                      AppStrings.navNewArrival,
                                      () {
                                        Navigator.pop(context);
                                        context.go(AppPaths.home);
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 20.0,
                                        bottom: 8.0,
                                      ),
                                      child:
                                          AppText.spaceMono(
                                                'NEW ✨',
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              )
                                              .animate(
                                                onPlay: (c) =>
                                                    c.repeat(reverse: true),
                                              )
                                              .fade(
                                                duration: 800.ms,
                                                begin: 0.3,
                                                end: 1.0,
                                              ),
                                    ),
                                  ],
                                ),
                                _buildMobileMenuItem(context, 1, 'MENS', () {
                                  Navigator.pop(context);
                                  context.go(AppPaths.categoryId('mens'));
                                }),
                                _buildMobileMenuItem(context, 2, 'WOMENS', () {
                                  Navigator.pop(context);
                                  context.go(AppPaths.categoryId('womens'));
                                }),

                                // _buildMobileMenuItem(
                                //   context,
                                //   3,
                                //   'PORTRAITS',
                                //   () {
                                //     Navigator.pop(context);
                                //     context.go(AppPaths.portraits);
                                //   },
                                // ),
                                // _buildMobileMenuItem(context, 4, 'AI LAB', () {
                                //   Navigator.pop(context);
                                //   context.go(AppPaths.generator);
                                // }),
                                const SizedBox(height: 12),
                                Container(
                                  height: 1,
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                                const SizedBox(height: 12),

                                _buildMobileMenuItem(
                                  context,
                                  5,
                                  'BAG  ($cartCount)',
                                  () {
                                    Navigator.pop(context);
                                    context.go(AppPaths.cart);
                                  },
                                ),
                                _buildMobileMenuItem(
                                  context,
                                  6,
                                  authStatus == AuthStatus.authenticated
                                      ? 'MY ACCOUNT'
                                      : 'LOGIN',
                                  () {
                                    Navigator.pop(context);
                                    if (authStatus ==
                                        AuthStatus.authenticated) {
                                      context.go(AppPaths.account);
                                    } else {
                                      context.go(AppPaths.auth);
                                    }
                                  },
                                ),
                                if (authStatus == AuthStatus.authenticated)
                                  _buildMobileMenuItem(
                                    context,
                                    7,
                                    'MY ORDERS',
                                    () {
                                      Navigator.pop(context);
                                      context.go(AppPaths.orders);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Footer
                        if (authStatus == AuthStatus.authenticated)
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.06),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonAccent,
                                  ),
                                  child: Center(
                                    child: AppText.bebas(
                                      (authUsername ?? 'U')[0],
                                      fontSize: 14,
                                      color: AppTheme.pureBlack,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AppText.spaceMono(
                                    authUsername ?? 'USER',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white.withValues(alpha: 0.5),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            child: AppText.spaceMono(
                              '© 2026 THE TOURERS.',
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.2),
                              letterSpacing: 1.5,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileMenuItem(
    BuildContext context,
    int index,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.neonAccent.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Creative glowing vertical bar indicator
              Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.neonAccent,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.neonAccent.withValues(alpha: 0.8),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  )
                  .animate(delay: (200 + index * 50).ms)
                  .scaleY(
                    begin: 0.0,
                    end: 1.0,
                    duration: 400.ms,
                    curve: Curves.easeOutCirc,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(width: 20),

              // Text sliding in with a cyberpunk shimmer
              Expanded(
                child:
                    AppText.bebas(
                          title,
                          fontSize: 22, // Slightly smaller text as requested
                          letterSpacing: 2.5,
                          color: Colors.white,
                        )
                        .animate(delay: (250 + index * 50).ms)
                        .slideX(
                          begin: 0.1,
                          end: 0,
                          duration: 400.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .fadeIn(duration: 300.ms)
                        .shimmer(
                          delay: (600 + index * 100)
                              .ms, // Shimmer plays after it settles
                          duration: 800.ms,
                          color: AppTheme.neonAccent.withValues(alpha: 0.5),
                        ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavLink(
    String title,
    Color color, {
    VoidCallback? onTap,
  }) {
    return _HoverColorText(title: title, color: color, onTap: onTap);
  }

  Widget _buildAnimatedIcon(IconData icon, Color color) {
    return _HoverColorIcon(icon: icon, color: color);
  }

  Widget _buildCartIcon(BuildContext context, Color color, int count) {
    return GestureDetector(
      onTap: () => context.go(AppPaths.cart),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildAnimatedIcon(Icons.shopping_bag_outlined, color),
            if (count > 0)
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonAccent,
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(color: AppTheme.pureBlack, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      count.toString(),
                      style: GoogleFonts.spaceMono(
                        color: AppTheme.pureBlack,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthIndicator(
    BuildContext context,
    Color color,
    AuthStatus authStatus,
    String? username,
  ) {
    if (authStatus == AuthStatus.authenticated) {
      final displayName = username ?? 'USER';
      return _buildAnimatedNavLink(
        'ACCOUNT // $displayName',
        color,
        onTap: () => context.go(AppPaths.account),
      );
    } else {
      return _buildAnimatedNavLink(
        'LOGIN',
        color,
        onTap: () => context.go(AppPaths.auth),
      );
    }
  }
}

class _HoverColorText extends StatefulWidget {
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const _HoverColorText({required this.title, required this.color, this.onTap});

  @override
  State<_HoverColorText> createState() => _HoverColorTextState();
}

class _HoverColorTextState extends State<_HoverColorText> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isHovered ? AppTheme.neonAccent : Colors.transparent,
            border: Border.all(
              color: _isHovered ? AppTheme.pureBlack : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            widget.title,
            style: GoogleFonts.spaceMono(
              color: _isHovered ? AppTheme.pureBlack : widget.color,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}

class _HoverColorIcon extends StatefulWidget {
  final IconData icon;
  final Color color;

  const _HoverColorIcon({required this.icon, required this.color});

  @override
  State<_HoverColorIcon> createState() => _HoverColorIconState();
}

class _HoverColorIconState extends State<_HoverColorIcon> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: _isHovered ? AppTheme.neonAccent : Colors.transparent,
          border: Border.all(
            color: _isHovered ? AppTheme.pureBlack : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Icon(
          widget.icon,
          color: _isHovered ? AppTheme.pureBlack : widget.color,
          size: 24,
        ),
      ),
    );
  }
}
