import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import '../../../../core/widgets/app_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/app_text.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/footer_section.dart';
import '../widgets/promo_banner.dart';
import '../../../../core/theme/app_theme.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top promo banner
            const PromoBanner(),

            // Brutalist header app bar
            const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),

            // Hero section: Manifesto
            WebConstrainedBox(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : 24.0,
                vertical: 48.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Giant Heading
                  AppText.bebas(
                    AppStrings.heroTitle,
                    fontSize: isDesktop ? 120 : 64,
                    height: 0.9,
                    letterSpacing: 4.0,
                    color: textColor,
                  ),
                  const SizedBox(height: AppSizes.p32),

                  // Divider line
                  Container(
                    height: 4,
                    width: double.infinity,
                    color: textColor,
                  ),
                  const SizedBox(height: AppSizes.p48),

                  // Dual Column layout on desktop, stack on mobile
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: AppText.bebas(
                                AppStrings.manifestoTitle,
                                fontSize: 48,
                                height: 1.0,
                                letterSpacing: 2.0,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 64),
                            Expanded(
                              flex: 7,
                              child: _buildStoryText(textColor, isDesktop),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.bebas(
                              AppStrings.manifestoTitle,
                              fontSize: 28,
                              height: 1.0,
                              letterSpacing: 2.0,
                              color: textColor,
                            ),
                            const SizedBox(height: 24),
                            _buildStoryText(textColor, isDesktop),
                          ],
                        ),
                ],
              ),
            ),

            // Craftsmanship Section: Core Pillars
            Container(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              width: double.infinity,
              child: WebConstrainedBox(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64.0 : 24.0,
                  vertical: 80.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.spaceMono(
                      AppStrings.benefitMarquee,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: textColor,
                    ),
                    const SizedBox(height: AppSizes.p48),

                    // Grid of pillars
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isDesktop ? 3 : 1,
                      crossAxisSpacing: AppSizes.p32,
                      mainAxisSpacing: AppSizes.p48,
                      childAspectRatio: isDesktop ? 0.95 : 1.2,
                      children: [
                        _buildPillarCard(
                          context,
                          '01',
                          AppStrings.pillar1Title,
                          AppStrings.pillar1Desc,
                          textColor,
                        ),
                        _buildPillarCard(
                          context,
                          '02',
                          AppStrings.pillar2Title,
                          AppStrings.pillar2Desc,
                          textColor,
                        ),
                        _buildPillarCard(
                          context,
                          '03',
                          AppStrings.pillar3Title,
                          AppStrings.pillar3Desc,
                          textColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Streetwear moodboard collage
            WebConstrainedBox(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 64.0 : 24.0,
                vertical: 80.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.spaceMono(
                    AppStrings.moodboardMarquee,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: textColor,
                  ),
                  const SizedBox(height: AppSizes.p48),

                  // Masonry style grid collage
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left column: big image
                            Expanded(
                              flex: 6,
                              child: _buildMoodImage(
                                'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=1000&auto=format&fit=crop',
                                550,
                              ),
                            ),
                            const SizedBox(width: AppSizes.p32),
                            // Right column: two stacked images
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _buildMoodImage(
                                    'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?q=80&w=800&auto=format&fit=crop',
                                    260,
                                  ),
                                  const SizedBox(height: AppSizes.p32),
                                  _buildMoodImage(
                                    'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?q=80&w=800&auto=format&fit=crop',
                                    260,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _buildMoodImage(
                              'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?q=80&w=800&auto=format&fit=crop',
                              350,
                            ),
                            const SizedBox(height: 24),
                            _buildMoodImage(
                              'https://images.unsplash.com/photo-1529374255404-311a2a4f1fd9?q=80&w=800&auto=format&fit=crop',
                              250,
                            ),
                          ],
                        ),
                ],
              ),
            ),

            // Call to Action (CTA) Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 80.0),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: textColor, width: 3)),
              ),
              child: WebConstrainedBox(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    AppText.bebas(
                      'BE PART OF THE MOVEMENT',
                      fontSize: isDesktop ? 64 : 32,
                      letterSpacing: 2.0,
                      color: textColor,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p8),
                    AppText.spaceMono(
                      'We drop capsules in highly limited batches. Secure your piece before they sell out.',
                      fontSize: isDesktop ? 14 : 12,
                      color: textColor.withValues(alpha: 0.7),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.p48),

                    // Big interactive brutalist CTA Button
                    BrutalistHoverWidget(
                      shadowColor: AppTheme.neonAccent,
                      offset: const Offset(8, 8),
                      child: SizedBox(
                        width: isDesktop ? 400 : double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              context.go(AppPaths.categoryId('mens')),
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
                          child: AppText.bebas(
                            'SHOP LATEST CAPSULES ↗',
                            fontSize: isDesktop ? 24 : 18,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stark footnotes section
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryText(Color textColor, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.spaceMono(
          AppStrings.manifestoSub1,
          fontSize: isDesktop ? 16 : 14,
          height: 1.7,
          color: textColor.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 24),
        AppText.spaceMono(
          AppStrings.manifestoSub2,
          fontSize: isDesktop ? 16 : 14,
          height: 1.7,
          color: textColor.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  Widget _buildPillarCard(
    BuildContext context,
    String index,
    String title,
    String description,
    Color textColor,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return BrutalistHoverWidget(
      shadowColor: AppTheme.neonAccent,
      offset: const Offset(6, 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: textColor, width: 3.0),
        ),
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row with Index Number and Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bebas(
                  index,
                  fontSize: isDesktop ? 48 : 36,
                  color: textColor.withValues(alpha: 0.25),
                ),
                Icon(
                  Icons.bolt,
                  color: textColor.withValues(alpha: 0.7),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Title
            AppText.spaceMono(
              title,
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: textColor,
            ),
            const SizedBox(height: 16),
            // Description
            Expanded(
              child: SingleChildScrollView(
                child: AppText.spaceMono(
                  description,
                  fontSize: isDesktop ? 13 : 11,
                  height: 1.6,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodImage(String url, double height) {
    return BrutalistHoverWidget(
      shadowColor: AppTheme.neonAccent,
      offset: const Offset(6, 6),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 3.0),
        ),
        child: AppImage(
          imageUrl: url,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          memCacheWidth: 600,
        ),
      ),
    );
  }
}
