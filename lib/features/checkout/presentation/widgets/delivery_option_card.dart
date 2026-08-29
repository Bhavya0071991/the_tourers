import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/delivery_method.dart';

class DeliveryOptionCard extends StatelessWidget {
  final DeliveryMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  const DeliveryOptionCard({
    super.key,
    required this.method,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final isDisabled = !method.isAvailable;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? textColor
              : isDisabled
                  ? textColor.withValues(alpha: 0.03)
                  : Colors.transparent,
          border: Border.all(
            color: isDisabled
                ? textColor.withValues(alpha: 0.15)
                : textColor,
            width: isSelected ? 3.0 : 2.0,
          ),
        ),
        child: Row(
          children: [
            // Radio indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDisabled
                      ? textColor.withValues(alpha: 0.2)
                      : isSelected
                          ? surfaceColor
                          : textColor,
                  width: 2,
                ),
                color: isSelected ? surfaceColor : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: textColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          method.title,
                          style: GoogleFonts.spaceMono(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDisabled
                                ? textColor.withValues(alpha: 0.3)
                                : isSelected
                                    ? surfaceColor
                                    : textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? surfaceColor
                              : method.charge == 0
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : textColor.withValues(alpha: 0.05),
                          border: Border.all(
                            color: isDisabled
                                ? textColor.withValues(alpha: 0.1)
                                : isSelected
                                    ? surfaceColor
                                    : method.charge == 0
                                        ? Colors.green
                                        : textColor.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          method.chargeDisplay,
                          style: GoogleFonts.spaceMono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? textColor
                                : method.charge == 0
                                    ? Colors.green
                                    : textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    method.description,
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      color: isDisabled
                          ? textColor.withValues(alpha: 0.2)
                          : (isSelected ? surfaceColor : textColor)
                              .withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 12,
                        color: isDisabled
                            ? textColor.withValues(alpha: 0.2)
                            : (isSelected ? surfaceColor : textColor)
                                .withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'EST: ${method.estimatedDays}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? textColor.withValues(alpha: 0.2)
                              : (isSelected ? surfaceColor : textColor)
                                  .withValues(alpha: 0.6),
                        ),
                      ),
                      if (isDisabled) ...[
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          child: Text(
                            'UNAVAILABLE',
                            style: GoogleFonts.spaceMono(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
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
