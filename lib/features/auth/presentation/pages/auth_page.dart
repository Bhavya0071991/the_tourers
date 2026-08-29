import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../home/presentation/widgets/promo_banner.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/brand_logo_icon.dart';

class AuthPage extends ConsumerStatefulWidget {
  const AuthPage({super.key});

  @override
  ConsumerState<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends ConsumerState<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleLogin() async {
    final authNotifier = ref.read(authProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);
    final errorMsg = await authNotifier.loginWithGoogle();
    if (errorMsg == null) {
      if (mounted) {
        AppSnackBar.showWithMessenger(messenger, AppStrings.authSuccess);
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppPaths.home);
        }
      }
    } else {
      AppSnackBar.showWithMessenger(messenger, errorMsg, isError: true);
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text;
    final messenger = ScaffoldMessenger.of(context);
    if (email.trim().isEmpty || !email.contains('@')) {
      AppSnackBar.showWithMessenger(
        messenger, 
        'Please enter a valid email address to reset password.', 
        isError: true,
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final errorMsg = await authNotifier.resetPassword(email);

    if (errorMsg == null) {
      if (mounted) {
        AppSnackBar.showWithMessenger(messenger, AppStrings.authResetPasswordSent);
      }
    } else {
      AppSnackBar.showWithMessenger(messenger, errorMsg, isError: true);
    }
  }

  Future<void> _handleAuthentication() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;

    final isLoginMode = ref.read(authLoginModeProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final messenger = ScaffoldMessenger.of(context);

    if (isLoginMode) {
      final errorMsg = await authNotifier.login(email, password);

      if (errorMsg == null) {
        if (mounted) {
          AppSnackBar.showWithMessenger(messenger, AppStrings.authSuccess);
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppPaths.home);
          }
        }
      } else {
        AppSnackBar.showWithMessenger(messenger, errorMsg, isError: true);
      }
    } else {
      final errorMsg = await authNotifier.register(email, password, name);

      if (errorMsg == null) {
        AppSnackBar.showWithMessenger(
          messenger,
          AppStrings.authVerificationLinkSent,
        );
        // Switch to login mode so they are ready to login after clicking the link
        ref.read(authLoginModeProvider.notifier).state = true;
      } else {
        AppSnackBar.showWithMessenger(messenger, errorMsg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // If the user is already authenticated (e.g. manually typed URL), redirect them to home.
    // Use a post-frame callback to avoid state modification during build.
    final authState = ref.watch(authProvider).value;
    if (authState?.status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go(AppPaths.home);
          }
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLoginMode = ref.watch(authLoginModeProvider);
    final isLoading = ref.watch(authProvider).isLoading;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const PromoBanner(),

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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrandLogoIcon(size: 32, color: textColor),
                          const SizedBox(width: 10),
                          AppText.bebas(
                            AppStrings.appName,
                            fontSize: 32,
                            letterSpacing: 1.0,
                            color: textColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppPaths.home);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.p24),
            // Form container
            WebConstrainedBox(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: BrutalistHoverWidget(
                    shadowColor: textColor.withValues(alpha: 0.15),
                    offset: const Offset(8, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        border: Border.all(color: textColor, width: 4.0),
                      ),
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Section watermark
                          AppText.spaceMono(
                            AppStrings.authAccessControl,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),

                          // Toggle Mode Tabs
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      ref
                                              .read(
                                                authLoginModeProvider.notifier,
                                              )
                                              .state =
                                          true,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isLoginMode
                                          ? textColor
                                          : surfaceColor,
                                      border: Border.all(
                                        color: textColor,
                                        width: 2.0,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: AppText.bebas(
                                      AppStrings.authLogin,
                                      fontSize: 20,
                                      color: isLoginMode
                                          ? surfaceColor
                                          : textColor,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: InkWell(
                                  onTap: () =>
                                      ref
                                              .read(
                                                authLoginModeProvider.notifier,
                                              )
                                              .state =
                                          false,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isLoginMode
                                          ? textColor
                                          : surfaceColor,
                                      border: Border.all(
                                        color: textColor,
                                        width: 2.0,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: AppText.bebas(
                                      AppStrings.authRegister,
                                      fontSize: 20,
                                      color: !isLoginMode
                                          ? surfaceColor
                                          : textColor,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          if (!isLoginMode) ...[
                            AppText.spaceMono(
                              AppStrings.authFullName,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            const SizedBox(height: 8),
                            AppField(
                              hintText: AppStrings.authFullNameHint,
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 20),
                          ],

                          AppText.spaceMono(
                            AppStrings.authEmail,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          const SizedBox(height: 8),
                          AppField(
                            hintText: AppStrings.authEmailHint,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          AppText.spaceMono(
                            AppStrings.authPassword,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          const SizedBox(height: 8),
                          AppField(
                            hintText: AppStrings.authPasswordHint,
                            controller: _passwordController,
                            obscureText: true,
                          ),

                          if (isLoginMode) ...[
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
                                  fontSize: 10,
                                  color: textColor.withValues(alpha: 0.8),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // Trigger Button
                          BrutalistHoverWidget(
                            shadowColor: textColor.withValues(alpha: 0.2),
                            offset: const Offset(4, 4),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : _handleAuthentication,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonAccent,
                                  foregroundColor: AppTheme.pureBlack,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: const BorderSide(
                                      color: AppTheme.pureBlack,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (isLoading)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 12.0),
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTheme.pureBlack,
                                          ),
                                        ),
                                      ),
                                    AppText.bebas(
                                      isLoginMode
                                          ? AppStrings.authInitSession
                                          : AppStrings.authCreateProfile,
                                      fontSize: 20,
                                      letterSpacing: 1.5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                ref
                                    .read(authLoginModeProvider.notifier)
                                    .update((state) => !state);
                              },
                              child: AppText.spaceMono(
                                isLoginMode
                                    ? AppStrings.authNewHere
                                    : AppStrings.authAlreadyRegistered,
                                fontSize: 10,
                                color: textColor.withValues(alpha: 0.6),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: textColor.withValues(alpha: 0.2),
                                  thickness: 2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: AppText.spaceMono(
                                  AppStrings.authOrContinueWith,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: textColor.withValues(alpha: 0.6),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: textColor.withValues(alpha: 0.2),
                                  thickness: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Google Auth Button
                          BrutalistHoverWidget(
                            shadowColor: textColor.withValues(alpha: 0.2),
                            offset: const Offset(4, 4),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleGoogleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: surfaceColor,
                                  foregroundColor: textColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
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
                                    // Custom G icon placeholder using text for robust rendering or use simple icon
                                    Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    AppText.bebas(
                                      AppStrings.authGoogle,
                                      fontSize: 18,
                                      letterSpacing: 1.5,
                                      color: textColor,
                                    ),
                                  ],
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
            ),

            const SizedBox(height: AppSizes.p64),
          ],
        ),
      ),
    );
  }
}
