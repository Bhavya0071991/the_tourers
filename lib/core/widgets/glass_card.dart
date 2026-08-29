import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double blur;
  final double opacity;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.blur = 12.0,
    this.opacity = 0.08,
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final effectiveBorderColor = borderColor ?? textColor.withValues(alpha: 0.15);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: opacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: effectiveBorderColor,
              width: borderWidth,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
