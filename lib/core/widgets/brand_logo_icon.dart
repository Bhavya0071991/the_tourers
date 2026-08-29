import 'package:flutter/material.dart';

/// A reusable brand logo icon widget that displays the TT monogram
/// with a premium animated gradient border and hover effects.
class BrandLogoIcon extends StatefulWidget {
  final double size;
  final Color color;

  const BrandLogoIcon({super.key, required this.size, required this.color});

  @override
  State<BrandLogoIcon> createState() => _BrandLogoIconState();
}

class _BrandLogoIconState extends State<BrandLogoIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isHovered = false;

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
    final borderRadius = BorderRadius.circular(8);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            transformAlignment: Alignment.center,
            transform: _isHovered
                ? (Matrix4.identity()
                    ..scale(1.12)
                    ..rotateZ(0.03))
                : Matrix4.identity(),
            child: Container(
              width: widget.size + 6,
              height: widget.size + 6,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
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
                margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: Image.asset(
                    'assets/images/logo_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
