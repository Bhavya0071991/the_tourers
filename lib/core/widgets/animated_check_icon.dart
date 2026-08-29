import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedCheckIcon extends StatefulWidget {
  final double size;
  final Color color;
  final Color? backgroundColor;
  final Duration duration;
  final Duration delay;

  const AnimatedCheckIcon({
    super.key,
    this.size = 120,
    this.color = Colors.white,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 1200),
    this.delay = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCheckIcon> createState() => _AnimatedCheckIconState();
}

class _AnimatedCheckIconState extends State<AnimatedCheckIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _circleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _circleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: CustomPaint(
              painter: _CheckPainter(
                circleProgress: _circleAnimation.value,
                checkProgress: _checkAnimation.value,
                color: widget.color,
                backgroundColor: widget.backgroundColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double circleProgress;
  final double checkProgress;
  final Color color;
  final Color? backgroundColor;

  _CheckPainter({
    required this.circleProgress,
    required this.checkProgress,
    required this.color,
    this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background fill
    if (backgroundColor != null && circleProgress > 0) {
      final bgPaint = Paint()
        ..color = backgroundColor!.withValues(alpha: circleProgress * 0.15)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius * circleProgress, bgPaint);
    }

    // Circle stroke
    if (circleProgress > 0) {
      final circlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final rect = Rect.fromCircle(center: center, radius: radius);
      final sweepAngle = 2 * pi * circleProgress;
      canvas.drawArc(rect, -pi / 2, sweepAngle, false, circlePaint);
    }

    // Checkmark
    if (checkProgress > 0) {
      final checkPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      final startX = size.width * 0.28;
      final startY = size.height * 0.52;
      final midX = size.width * 0.44;
      final midY = size.height * 0.66;
      final endX = size.width * 0.72;
      final endY = size.height * 0.36;

      path.moveTo(startX, startY);

      if (checkProgress <= 0.5) {
        // First segment of check
        final t = checkProgress / 0.5;
        path.lineTo(
          startX + (midX - startX) * t,
          startY + (midY - startY) * t,
        );
      } else {
        // Full first segment + partial second
        path.lineTo(midX, midY);
        final t = (checkProgress - 0.5) / 0.5;
        path.lineTo(
          midX + (endX - midX) * t,
          midY + (endY - midY) * t,
        );
      }

      canvas.drawPath(path, checkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) {
    return oldDelegate.circleProgress != circleProgress ||
        oldDelegate.checkProgress != checkProgress;
  }
}
