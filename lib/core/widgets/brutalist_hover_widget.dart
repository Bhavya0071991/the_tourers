import 'package:flutter/material.dart';

class BrutalistHoverWidget extends StatefulWidget {
  final Widget child;
  final Color shadowColor;
  final Offset offset;
  final bool invertColorsOnHover;
  final VoidCallback? onTap;

  const BrutalistHoverWidget({
    super.key,
    required this.child,
    this.shadowColor = Colors.black,
    this.offset = const Offset(6, 6),
    this.invertColorsOnHover = false,
    this.onTap,
  });

  @override
  State<BrutalistHoverWidget> createState() => _BrutalistHoverWidgetState();
}

class _BrutalistHoverWidgetState extends State<BrutalistHoverWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 100,
          ), // Very fast, snappy animation
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(
              _isHovered && !_isPressed ? -widget.offset.dx / 2 : 0.0,
              _isHovered && !_isPressed ? -widget.offset.dy / 2 : 0.0,
              0.0,
            )
            ..scale(_isPressed ? 0.98 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            boxShadow: [
              if (_isHovered && !_isPressed)
                BoxShadow(
                  color: widget.shadowColor,
                  offset: widget.offset,
                  blurRadius: 0, // Hard shadow
                  spreadRadius: 0,
                ),
            ],
          ),
          // If invertColorsOnHover is true, we could use a ColorFiltered, but for now we just use the shadow
          child: widget.child,
        ),
      ),
    );
  }
}
