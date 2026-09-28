import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/constants/app_strings.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/footer_section.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: CustomAppBar()),
          SliverToBoxAdapter(
            child: WebConstrainedBox(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : 24.0,
                vertical: isDesktop ? 80.0 : 40.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppText.spaceMono(
                            'BACK',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isDesktop ? 32 : 16),
                  AppText.bebas(
                    AppStrings.tosTitle,
                    fontSize: isDesktop ? 64 : 40,
                    letterSpacing: 2.0,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(height: 24),
                  AppText.spaceMono(
                    '${AppStrings.tosLastUpdated}${DateTime.now().year}',
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 48),

                  _buildSection(
                    context,
                    AppStrings.tosSection1Title,
                    AppStrings.tosSection1Body,
                  ),
                  _buildSection(
                    context,
                    AppStrings.tosSection2Title,
                    AppStrings.tosSection2Body,
                  ),
                  _buildSection(
                    context,
                    AppStrings.tosSection3Title,
                    AppStrings.tosSection3Body,
                  ),
                  _buildSection(
                    context,
                    AppStrings.tosSection4Title,
                    AppStrings.tosSection4Body,
                  ),
                  _buildSection(
                    context,
                    AppStrings.tosSection5Title,
                    AppStrings.tosSection5Body,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: FooterSection()),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.spaceMono(
            title,
            fontSize: isDesktop ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          AppText.spaceMono(
            content,
            fontSize: isDesktop ? 16 : 14,
            height: 1.6,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }
}
