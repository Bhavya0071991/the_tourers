import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/extensions/build_context_extension.dart';
import '../providers/product_details_provider.dart';

enum FitPreference { tight, regular, oversized }

class SmartFitFinderModal extends ConsumerStatefulWidget {
  const SmartFitFinderModal({super.key});

  @override
  ConsumerState<SmartFitFinderModal> createState() => _SmartFitFinderModalState();
}

class _SmartFitFinderModalState extends ConsumerState<SmartFitFinderModal> {
  double _heightCm = 175;
  double _weightKg = 70;
  FitPreference _fitPref = FitPreference.regular;
  
  bool _isCalculating = false;
  String? _recommendedSize;

  void _calculateFit() async {
    setState(() {
      _isCalculating = true;
    });

    // Simulate network delay for premium feel
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Basic Logic based on BMI
    final heightM = _heightCm / 100;
    final bmi = _weightKg / (heightM * heightM);

    int sizeLevel = 1; // 0=S, 1=M, 2=L, 3=XL
    if (bmi < 18.5) {
      sizeLevel = 0;
    } else if (bmi < 25) {
      sizeLevel = 1;
    } else if (bmi < 30) {
      sizeLevel = 2;
    } else {
      sizeLevel = 3;
    }

    if (_fitPref == FitPreference.oversized) {
      sizeLevel++;
    } else if (_fitPref == FitPreference.tight) {
      sizeLevel--;
    }

    // Clamp between 0 (S) and 3 (XL)
    sizeLevel = sizeLevel.clamp(0, 3);

    const sizes = ['S', 'M', 'L', 'XL'];
    final recommended = sizes[sizeLevel];

    setState(() {
      _isCalculating = false;
      _recommendedSize = recommended;
    });
  }

  void _applySizeAndClose() {
    if (_recommendedSize != null) {
      ref.read(productDetailsProvider.notifier).updateSize(_recommendedSize!);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        border: Border.all(color: context.colorScheme.onSurface, width: 4),
      ),
      padding: const EdgeInsets.all(24.0),
      child: _recommendedSize == null
          ? _buildQuiz(context)
          : _buildResult(context),
    );
  }

  Widget _buildQuiz(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bebas(
          'SMART FIT FINDER',
          fontSize: 32,
          color: context.colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        AppText.spaceMono(
          'TELL US YOUR STATS, WE\'LL FIND YOUR PERFECT FIT.',
          fontSize: 12,
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 32),

        // Height Slider
        AppText.spaceMono(
          'HEIGHT: ${_heightCm.round()} CM',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        Slider(
          value: _heightCm,
          min: 140,
          max: 220,
          divisions: 80,
          activeColor: AppTheme.neonAccent,
          inactiveColor: context.colorScheme.onSurface.withValues(alpha: 0.2),
          onChanged: (val) => setState(() => _heightCm = val),
        ),
        const SizedBox(height: 16),

        // Weight Slider
        AppText.spaceMono(
          'WEIGHT: ${_weightKg.round()} KG',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        Slider(
          value: _weightKg,
          min: 40,
          max: 150,
          divisions: 110,
          activeColor: AppTheme.neonAccent,
          inactiveColor: context.colorScheme.onSurface.withValues(alpha: 0.2),
          onChanged: (val) => setState(() => _weightKg = val),
        ),
        const SizedBox(height: 32),

        // Fit Preference
        AppText.spaceMono(
          'HOW DO YOU LIKE YOUR FIT?',
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: FitPreference.values.map((pref) {
            final isSelected = _fitPref == pref;
            final label = pref.name.toUpperCase();
            return GestureDetector(
              onTap: () => setState(() => _fitPref = pref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? context.colorScheme.onSurface : Colors.transparent,
                  border: Border.all(color: context.colorScheme.onSurface, width: 2),
                ),
                child: AppText.spaceMono(
                  label,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? context.colorScheme.surface : context.colorScheme.onSurface,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 48),

        // Calculate Button
        BrutalistHoverWidget(
          shadowColor: context.colorScheme.onSurface,
          offset: const Offset(4, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isCalculating ? null : _calculateFit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonAccent,
                foregroundColor: AppTheme.pureBlack,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: const BorderSide(color: AppTheme.pureBlack, width: 2),
                ),
              ),
              child: _isCalculating
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: AppTheme.pureBlack, strokeWidth: 2),
                    )
                  : AppText.spaceMono(
                      'CALCULATE SIZE',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResult(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        AppText.bebas(
          'YOUR PERFECT FIT IS',
          fontSize: 32,
          color: context.colorScheme.onSurface,
        ),
        const SizedBox(height: 24),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: context.colorScheme.onSurface,
            border: Border.all(color: AppTheme.neonAccent, width: 4),
          ),
          child: Center(
            child: AppText.bebas(
              _recommendedSize!,
              fontSize: 64,
              color: AppTheme.neonAccent,
            ),
          ),
        ),
        const SizedBox(height: 48),
        BrutalistHoverWidget(
          shadowColor: context.colorScheme.onSurface,
          offset: const Offset(4, 4),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applySizeAndClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonAccent,
                foregroundColor: AppTheme.pureBlack,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: const BorderSide(color: AppTheme.pureBlack, width: 2),
                ),
              ),
              child: AppText.spaceMono(
                'APPLY & CLOSE',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _recommendedSize = null;
            });
          },
          child: AppText.spaceMono(
            'RETAKE QUIZ',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }
}
