import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentMethodCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isRecommended;

  const PaymentMethodCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isSelected = false,
    this.onTap,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? textColor : Colors.transparent,
          border: Border.all(
            color: textColor,
            width: isSelected ? 3.0 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? surfaceColor.withValues(alpha: 0.15)
                    : textColor.withValues(alpha: 0.05),
                border: Border.all(
                  color: (isSelected ? surfaceColor : textColor)
                      .withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? surfaceColor : textColor,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceMono(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? surfaceColor : textColor,
                        ),
                      ),
                      if (isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: Colors.green.withValues(alpha: isSelected ? 0.3 : 0.1),
                          child: Text(
                            'RECOMMENDED',
                            style: GoogleFonts.spaceMono(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.greenAccent : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: (isSelected ? surfaceColor : textColor)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? surfaceColor : textColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: surfaceColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
