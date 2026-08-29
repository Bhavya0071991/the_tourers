import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_field.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_paths.dart';
import 'package:url_launcher/url_launcher.dart';

class FooterSection extends StatefulWidget {
  const FooterSection({super.key});

  @override
  State<FooterSection> createState() => _FooterSectionState();
}

class _FooterSectionState extends State<FooterSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final textColor = Theme.of(context).colorScheme.onSurface;
    final fadedTextColor = textColor.withValues(alpha: 0.5);

    return Container(
      color: Colors
          .transparent, // Inherits global scaffold background without stacking
      child: Stack(
        children: [
          // Background Watermark Text
          Positioned(
            bottom: -40,
            left: 0,
            right: 0,
            child: AppText.bebas(
              AppStrings.footerWatermark,
              textAlign: TextAlign.center,
              maxLines: 1,
              fontSize: isDesktop ? 220 : 60,
              color: textColor.withValues(alpha: 0.03),
              height: 1.0,
              letterSpacing: 5.0,
            ),
          ),

          // Content
          WebConstrainedBox(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 64.0 : 24.0,
              vertical: 80.0,
            ),
            child: isDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Column: Logo & Info
                      Expanded(
                        flex: 2,
                        child: _buildLogoColumn(
                          context,
                          textColor,
                          fadedTextColor,
                        ),
                      ),

                      // Center Columns: Links
                      Expanded(
                        flex: 1,
                        child: _buildLinkColumn(
                          AppStrings.footerColShops,
                          [
                            AppStrings.navNewArrival,
                            AppStrings.navMens,
                            AppStrings.navWomens,
                            'WINTER',
                          ],
                          textColor,
                          fadedTextColor,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildLinkColumn(
                          AppStrings.footerColBrand,
                          ['ABOUT US', 'CONTACT'],
                          textColor,
                          fadedTextColor,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildLinkColumn(
                          AppStrings.footerColFollow,
                          ['INSTAGRAM', "DESIGNER'S INSTAGRAM"],
                          textColor,
                          fadedTextColor,
                        ),
                      ),

                      // Right Column: Newsletter
                      Expanded(
                        flex: 3,
                        child: _buildNewsletterColumn(
                          context,
                          textColor,
                          fadedTextColor,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLogoColumn(context, textColor, fadedTextColor),
                      const SizedBox(height: 48),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildLinkColumn(
                              AppStrings.footerColShops,
                              [
                                AppStrings.navNewArrival,
                                AppStrings.navMens,
                                AppStrings.navWomens,
                                'WINTER',
                              ],
                              textColor,
                              fadedTextColor,
                            ),
                          ),
                          Expanded(
                            child: _buildLinkColumn(
                              AppStrings.footerColBrand,
                              ['ABOUT US', 'CONTACT'],
                              textColor,
                              fadedTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildLinkColumn(
                        AppStrings.footerColFollow,
                        ['INSTAGRAM', 'DESIGNER INSTAGRAM'],
                        textColor,
                        fadedTextColor,
                      ),
                      const SizedBox(height: 48),
                      _buildNewsletterColumn(
                        context,
                        textColor,
                        fadedTextColor,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoColumn(
    BuildContext context,
    Color textColor,
    Color fadedTextColor,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Animated gradient-bordered logo
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return Container(
                  width: isDesktop ? 52 : 40,
                  height: isDesktop ? 52 : 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: SweepGradient(
                      startAngle: _glowController.value * 6.28,
                      colors: [
                        Colors.black,
                        Colors.grey.shade500,
                        Colors.white,
                        Colors.grey.shade500,
                        Colors.black,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.08 + (_glowController.value * 0.12),
                        ),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/logo_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bebas(
                    AppStrings.appName,
                    color: textColor,
                    fontSize: isDesktop ? 40 : 28,
                    letterSpacing: 2.0,
                    height: 1.0,
                  ),
                  const SizedBox(height: 4),
                  AppText.spaceMono(
                    'EST. 2026  //  FROM HIMALAYAS',
                    color: fadedTextColor,
                    fontSize: isDesktop ? 10 : 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: isDesktop ? 2.0 : 1.0,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 64),
        AppText.spaceMono(
          AppStrings.footerCopyright,
          color: fadedTextColor,
          fontSize: isDesktop ? 12 : 10,
          height: 1.8,
          decoration: TextDecoration.underline,
        ),
      ],
    );
  }

  Widget _buildLinkColumn(
    String title,
    List<String> links,
    Color textColor,
    Color fadedTextColor,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.spaceMono(
          title,
          color: fadedTextColor,
          fontSize: isDesktop ? 14 : 11,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 16),
        Container(
          width: 40,
          height: 1,
          color: fadedTextColor.withValues(alpha: 0.3),
        ),
        const SizedBox(height: 24),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: InkWell(
              onTap: () async {
                if (link == 'ABOUT US') {
                  context.go(AppPaths.about);
                } else if (link == 'INSTAGRAM') {
                  final url = Uri.parse('https://www.instagram.com/the_tourers?igsi=MXB5NHkyaTY1dnhuYQ==');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                } else if (link == "DESIGNER'S INSTAGRAM") {
                  final url = Uri.parse('https://www.instagram.com/pranxhu?igsi=bWFvZm4xeWZmc241');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                }
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AppText.spaceMono(
                  link,
                  color: textColor,
                  fontSize: isDesktop ? 14 : 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewsletterColumn(
    BuildContext context,
    Color textColor,
    Color fadedTextColor,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Padding(
      padding: EdgeInsets.only(left: isDesktop ? 32.0 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            AppStrings.footerNewsletterTitle,
            color: textColor,
            fontSize: isDesktop ? 40 : 28,
            letterSpacing: 1.5,
          ),
          const SizedBox(height: 16),
          AppText.spaceMono(
            AppStrings.footerNewsletterDesc,
            color: textColor.withValues(alpha: 0.8),
            fontSize: isDesktop ? 14 : 11,
            height: 1.6,
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AppField(hintText: AppStrings.footerNewsletterEmail),
              ),
              const SizedBox(width: 8),
              Material(
                color: Theme.of(
                  context,
                ).colorScheme.primary, // Increased visibility
                child: InkWell(
                  onTap: () {}, // Make the button clickable
                  child: Container(
                    height: 58, // Match standard height of AppField
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 32 : 20,
                    ),
                    alignment: Alignment.center,
                    child: AppText.spaceMono(
                      AppStrings.footerNewsletterSubscribe,
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.w700,
                      fontSize: isDesktop ? 14 : 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
