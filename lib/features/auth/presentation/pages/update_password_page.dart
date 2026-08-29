import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_paths.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  ConsumerState<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdatePassword() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final messenger = ScaffoldMessenger.of(context);

    if (password != confirmPassword) {
      AppSnackBar.showWithMessenger(
        messenger,
        'Passwords do not match.',
        isError: true,
      );
      return;
    }

    if (password.trim().length < 6) {
      AppSnackBar.showWithMessenger(
        messenger,
        'Password must be at least 6 characters.',
        isError: true,
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final errorMsg = await authNotifier.updatePassword(password);

    if (errorMsg == null) {
      if (mounted) {
        AppSnackBar.showWithMessenger(
          messenger,
          'Password updated successfully!',
        );
        final authState = ref.read(authProvider).value;
        if (authState != null && (authState.role == 'admin' || authState.role == 'super_admin')) {
          context.go(AppPaths.adminDashboard);
        } else {
          context.go(AppPaths.home);
        }
      }
    } else {
      if (mounted) {
        AppSnackBar.showWithMessenger(messenger, errorMsg, isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: AppText.bebas(
          'SET NEW PASSWORD',
          fontSize: 24,
          letterSpacing: 1.0,
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: WebConstrainedBox(
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
                    AppText.spaceMono(
                      '/// SECURITY PROTOCOL',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 24),
                    AppText.spaceMono(
                      'NEW PASSWORD',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    const SizedBox(height: 8),
                    AppField(
                      hintText: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    AppText.spaceMono(
                      'CONFIRM NEW PASSWORD',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    const SizedBox(height: 8),
                    AppField(
                      hintText: '••••••••',
                      controller: _confirmPasswordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),
                    BrutalistHoverWidget(
                      shadowColor: textColor.withValues(alpha: 0.2),
                      offset: const Offset(4, 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleUpdatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonAccent,
                            foregroundColor: AppTheme.pureBlack,
                            padding: const EdgeInsets.symmetric(vertical: 24),
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
                                'UPDATE PASSWORD ↗',
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
            ),
          ),
        ),
      ),
    );
  }
}
