import 'package:flutter/material.dart';

class ImageZoomOnHover extends StatefulWidget {
  final Widget child;
  final double zoomScale;

  const ImageZoomOnHover({
    super.key,
    required this.child,
    this.zoomScale = 1.5, // Decreased default zoom scale
  });

  @override
  State<ImageZoomOnHover> createState() => _ImageZoomOnHoverState();
}

class _ImageZoomOnHoverState extends State<ImageZoomOnHover> {
  bool _isHovering = false;
  Offset _mousePosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.zoomIn, // Added zoom cursor
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      onHover: (event) {
        setState(() {
          _mousePosition = event.localPosition;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          // Prevent division by zero if layout is empty
          if (width == 0 || height == 0) return widget.child;

          final fractionalX = (_mousePosition.dx / width).clamp(0.0, 1.0);
          final fractionalY = (_mousePosition.dy / height).clamp(0.0, 1.0);

          return ClipRect(
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              tween: Tween<double>(
                begin: 1.0,
                end: _isHovering ? widget.zoomScale : 1.0,
              ),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  alignment: FractionalOffset(fractionalX, fractionalY),
                  child: child,
                );
              },
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
