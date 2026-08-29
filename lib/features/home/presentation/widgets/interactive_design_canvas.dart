import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';

/// An interactive gestural canvas wrapper that enables dragging, scaling,
/// and repositioning of the customizable print area on a T-shirt mockup.
///
/// It utilizes [GestureDetector]'s multi-touch scaling and pan deltas
/// to deliver a premium, fluid desktop/mobile clothing design experience.
class InteractiveDesignCanvas extends StatefulWidget {
  final Widget child;
  final double initialScale;
  final Offset initialOffset;
  final ValueChanged<double>? onScaleChanged;
  final ValueChanged<Offset>? onOffsetChanged;

  const InteractiveDesignCanvas({
    super.key,
    required this.child,
    this.initialScale = 1.0,
    this.initialOffset = Offset.zero,
    this.onScaleChanged,
    this.onOffsetChanged,
  });

  @override
  State<InteractiveDesignCanvas> createState() =>
      _InteractiveDesignCanvasState();
}

class _InteractiveDesignCanvasState extends State<InteractiveDesignCanvas> {
  late double _scale;
  late Offset _offset;

  late double _baseScale;
  late Offset _baseOffset;

  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale;
    _offset = widget.initialOffset;
  }

  @override
  void didUpdateWidget(covariant InteractiveDesignCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync state only if parent resets coordinates specifically
    if (oldWidget.initialScale != widget.initialScale ||
        oldWidget.initialOffset != widget.initialOffset) {
      setState(() {
        _scale = widget.initialScale;
        _offset = widget.initialOffset;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final parentWidth = constraints.maxWidth;
        final parentHeight = constraints.maxHeight;

        // Bounding limits to prevent graphic from flying off the garment
        final double maxDx = parentWidth * 0.38;
        final double minDx = -parentWidth * 0.38;
        final double maxDy = parentHeight * 0.4;
        final double minDy = -parentHeight * 0.3;

        return GestureDetector(
          onScaleStart: (details) {
            setState(() {
              _isInteracting = true;
              _baseScale = _scale;
              _baseOffset = _offset;
            });
          },
          onScaleUpdate: (details) {
            setState(() {
              // 1. Process Resize / Scale with safe boundaries (between 0.4x and 2.2x)
              _scale = (_baseScale * details.scale).clamp(0.4, 2.2);
              widget.onScaleChanged?.call(_scale);

              // 2. Process Drag / Reposition with safe clamping bounds
              final rawOffset = _baseOffset + details.focalPointDelta;
              _offset = Offset(
                rawOffset.dx.clamp(minDx, maxDx),
                rawOffset.dy.clamp(minDy, maxDy),
              );
              widget.onOffsetChanged?.call(_offset);
            });
          },
          onScaleEnd: (details) {
            setState(() {
              _isInteracting = false;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bounding technical grid outline shown when interacting
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _isInteracting ? 0.35 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF00FFCC),
                          width: 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            color: const Color(
                              0xFF00FFCC,
                            ).withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 100),
                          Container(
                            height: 1,
                            color: const Color(
                              0xFF00FFCC,
                            ).withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Transformed Printable overlay
              Transform.translate(
                offset: _offset,
                child: Transform.scale(
                  scale: _scale,
                  child: Container(
                    decoration: BoxDecoration(
                      // Draws a technical cyan dash highlight during edits
                      border: Border.all(
                        color: _isInteracting
                            ? const Color(0xFF00FFCC).withValues(alpha: 0.8)
                            : Colors.transparent,
                        width: 1.2,
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // The core design print block
                        widget.child,

                        // Floating Spec Badge shown live during drag/resize
                        if (_isInteracting)
                          Positioned(
                            bottom: -28,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F0F13),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF00FFCC,
                                    ).withValues(alpha: 0.5),
                                    width: 1.0,
                                  ),
                                ),
                                child: AppText.spaceMono(
                                  "SCALE: ${(_scale * 100).toInt()}%  //  OFFSET: [${_offset.dx.toInt()}, ${_offset.dy.toInt()}]",
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF00FFCC),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
