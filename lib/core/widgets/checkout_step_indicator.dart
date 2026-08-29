import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutStepIndicator extends StatelessWidget {
  final int currentStep;

  static const List<String> _steps = ['BAG', 'ADDRESS', 'DELIVERY', 'PAYMENT'];

  const CheckoutStepIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: textColor.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Connector line
            final stepIndex = index ~/ 2;
            final isCompleted = stepIndex < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: isCompleted
                    ? textColor
                    : textColor.withValues(alpha: 0.15),
              ),
            );
          }

          // Step indicator
          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return _StepDot(
            label: _steps[stepIndex],
            isActive: isActive,
            isCompleted: isCompleted,
            textColor: textColor,
            surfaceColor: surfaceColor,
            stepNumber: stepIndex + 1,
          );
        }),
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;
  final Color textColor;
  final Color surfaceColor;
  final int stepNumber;

  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.textColor,
    required this.surfaceColor,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 28 : 24,
          height: isActive ? 28 : 24,
          decoration: BoxDecoration(
            color: (isActive || isCompleted) ? textColor : Colors.transparent,
            border: Border.all(
              color: textColor.withValues(alpha: isActive || isCompleted ? 1.0 : 0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, size: 14, color: surfaceColor)
                : Text(
                    '$stepNumber',
                    style: GoogleFonts.spaceMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isActive ? surfaceColor : textColor.withValues(alpha: 0.4),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 8,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: (isActive || isCompleted)
                ? textColor
                : textColor.withValues(alpha: 0.35),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
