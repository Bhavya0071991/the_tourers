import 'package:flutter/material.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    super.key,
    this.width = double.infinity,
    this.height = 20,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.04, end: 0.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            color: textColor.withValues(alpha: _animation.value),
          ),
        );
      },
    );
  }
}

/// A card-shaped skeleton for order/product cards
class SkeletonCard extends StatelessWidget {
  final double height;

  const SkeletonCard({super.key, this.height = 120});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: textColor.withValues(alpha: 0.1), width: 2),
      ),
      child: Row(
        children: [
          SkeletonLoader(width: 100, height: height),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SkeletonLoader(width: 160, height: 14),
                  const SizedBox(height: 10),
                  SkeletonLoader(
                    width: 100,
                    height: 10,
                    margin: const EdgeInsets.only(bottom: 10),
                  ),
                  const SkeletonLoader(width: 80, height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
