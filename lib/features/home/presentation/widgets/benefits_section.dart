import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/fade_in_slide_widget.dart';
import '../../../../core/widgets/app_text.dart';

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    
    final cards = [
      FadeInSlideWidget(
        delay: Duration.zero,
        child: const _AnimatedBenefitCard(
          icon: Icons.dry_cleaning_outlined,
          title: AppStrings.benefit1Title,
          description: AppStrings.benefit1Desc,
        ),
      ),
      FadeInSlideWidget(
        delay: const Duration(milliseconds: 150),
        child: const _AnimatedBenefitCard(
          icon: Icons.iron_outlined,
          title: AppStrings.benefit2Title,
          description: AppStrings.benefit2Desc,
        ),
      ),
      FadeInSlideWidget(
        delay: const Duration(milliseconds: 300),
        child: const _AnimatedBenefitCard(
          icon: Icons.local_laundry_service_outlined,
          title: AppStrings.benefit3Title,
          description: AppStrings.benefit3Desc,
        ),
      ),
      FadeInSlideWidget(
        delay: const Duration(milliseconds: 450),
        child: const _AnimatedBenefitCard(
          icon: Icons.format_color_reset_outlined,
          title: AppStrings.benefit4Title,
          description: AppStrings.benefit4Desc,
        ),
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.p48),
      child: WebConstrainedBox(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p24),
        child: isDesktop 
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: cards.map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: AppSizes.p24),
                    child: c,
                  ),
                )).toList(),
              )
            : Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: AppSizes.p32,
                runSpacing: AppSizes.p32,
                children: cards,
              ),
      ),
    );
  }
}

class _AnimatedBenefitCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;

  const _AnimatedBenefitCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  State<_AnimatedBenefitCard> createState() => _AnimatedBenefitCardState();
}

class _AnimatedBenefitCardState extends State<_AnimatedBenefitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -8.0 : 0.0, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width > 900 ? double.infinity : 250,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon with scale and color transitions
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(AppSizes.p12),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? primaryColor
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: AnimatedRotation(
                  turns: _isHovered ? 0.05 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    widget.icon,
                    size: MediaQuery.of(context).size.width > 900 ? 32 : 24,
                    color: _isHovered
                        ? Theme.of(context).colorScheme.surface
                        : primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    AppText.spaceMono(
                      widget.title,
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.of(context).size.width > 900 ? 18 : 15,
                      color: primaryColor,
                    ),
                    const SizedBox(height: AppSizes.p8),

                    // Description
                    AppText.spaceMono(
                      widget.description,
                      textAlign: TextAlign.left,
                      fontSize: MediaQuery.of(context).size.width > 900 ? 14 : 12,
                      color: primaryColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
