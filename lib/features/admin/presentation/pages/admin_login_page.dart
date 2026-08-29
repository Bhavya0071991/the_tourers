import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../features/auth/providers/auth_provider.dart';
class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      final errorMsg = await ref.read(authProvider.notifier).login(email, password);
      
      if (!mounted) return;

      if (errorMsg == null) {
        // Fetch current state to check role
        final authState = ref.read(authProvider).value;
        if (authState != null && (authState.role == 'admin' || authState.role == 'super_admin')) {
          AppSnackBar.show(context, AppStrings.adminLoginSuccess);
          context.go(AppPaths.adminDashboard);
        } else {
          // Logout immediately if they are not admin
          ref.read(authProvider.notifier).logout();
          AppSnackBar.show(context, AppStrings.adminAccessDenied, isError: true);
        }
      } else {
        AppSnackBar.show(context, errorMsg, isError: true);
      }
    } else {
      AppSnackBar.show(context, AppStrings.adminEnterEmailPassword);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      AppSnackBar.show(context, 'Please enter a valid email address to reset password.', isError: true);
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final errorMsg = await authNotifier.resetPassword(email);

    if (!mounted) return;

    if (errorMsg == null) {
      AppSnackBar.show(context, AppStrings.authResetPasswordSent);
    } else {
      AppSnackBar.show(context, errorMsg, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Minimalist Header
            WebConstrainedBox(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : 24.0,
                vertical: 24.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppPaths.home),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AppText.bebas(
                        AppStrings.adminHeaderTitle,
                        color: textColor,
                        fontSize: isDesktop ? 32 : 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form Area
            WebConstrainedBox(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : 24.0,
                vertical: 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText.bebas(
                    AppStrings.adminLoginTitle,
                    color: textColor,
                    fontSize: isDesktop ? 64 : 48,
                    height: 0.9,
                  ),
                  const SizedBox(height: 16),
                  AppText.spaceMono(
                    AppStrings.adminLoginSubtitle,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 48),

                  AppField(
                    controller: _emailController,
                    hintText: AppStrings.adminEmailHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  AppField(
                    controller: _passwordController,
                    hintText: AppStrings.adminPasswordHint,
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _handleForgotPassword,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: AppText.spaceMono(
                        AppStrings.authForgotPassword,
                        color: textColor.withValues(alpha: 0.8),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),

                  BrutalistHoverWidget(
                    shadowColor: textColor.withValues(alpha: 0.2),
                    offset: const Offset(4, 4),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _handleAdminLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: textColor,
                          foregroundColor: surfaceColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0),
                            side: BorderSide(
                              color: textColor,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isLoading)
                              Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: surfaceColor,
                                  ),
                                ),
                              ),
                            AppText.bebas(
                              AppStrings.adminEnterDashboard,
                              color: surfaceColor,
                              fontSize: 20,
                              letterSpacing: 1.5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
