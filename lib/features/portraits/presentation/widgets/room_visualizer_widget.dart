import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text.dart';

class RoomVisualizerWidget extends StatefulWidget {
  final String imageUrl;
  final String selectedSize; // 'A4', 'A3', 'A2'
  final String
  selectedFrame; // 'Classic Black', 'Natural Oak', 'Neon Acrylic', 'Unframed'

  const RoomVisualizerWidget({
    super.key,
    required this.imageUrl,
    required this.selectedSize,
    required this.selectedFrame,
  });

  @override
  State<RoomVisualizerWidget> createState() => _RoomVisualizerWidgetState();
}

class _RoomVisualizerWidgetState extends State<RoomVisualizerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanlineController;

  @override
  void initState() {
    super.initState();
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _scanlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFE8E0D5); // Warm Beige

    // Determine sizing dimensions on the screen
    double widthMultiplier = 1.0;
    if (widget.selectedSize == 'A3') widthMultiplier = 1.25;
    if (widget.selectedSize == 'A2') widthMultiplier = 1.5;

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final baseWidth = 140.0 * widthMultiplier;
    final baseHeight = 196.0 * widthMultiplier;

    return Container(
      width: double.infinity,
      height: isDesktop ? 480 : 350,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface,
          width: 3,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Room Background with animated crossfade
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Container(key: ValueKey(bgColor), color: bgColor),
            ),
          ),

          // 2. Poster Frame on Wall with smooth size transition
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            width: baseWidth,
            height: baseHeight,
            margin: EdgeInsets.zero,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 28,
                  spreadRadius: 3,
                  offset: const Offset(8, 14),
                ),
              ],
            ),
            child: _buildFramedArtwork(context),
          ),

          // 3. Corner Markers removed per request

          // 4. Animated Scanline effect (subtle cyberpunk touch)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanlineController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ScanlinePainter(
                    progress: _scanlineController.value,
                    color: AppTheme.neonAccent.withValues(alpha: 0.06),
                  ),
                );
              },
            ),
          ),

          // 5. Designer signature watermark on background
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              'Pranxhu',
              style: GoogleFonts.greatVibes(
                fontSize: 25,
                color: Colors.black.withValues(alpha: 0.4),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // 6. Sizing guide tag overlay (bottom-right)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              color: AppTheme.pureBlack.withValues(alpha: 0.9),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText.spaceMono(
                    'SIZE REF: ${widget.selectedSize}'.toUpperCase(),
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.straighten, size: 12, color: Colors.white54),
                ],
              ),
            ),
          ),

          // 7. Frame Type indicator (top-center)
          Positioned(
            top: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(widget.selectedFrame),
                color: AppTheme.pureBlack.withValues(alpha: 0.9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                child: AppText.spaceMono(
                  'FRAME: ${widget.selectedFrame}'.toUpperCase(),
                  fontSize: 9,
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFramedArtwork(BuildContext context) {
    // Outer border styles mapping
    BoxDecoration frameDecoration;
    EdgeInsets framePadding;

    switch (widget.selectedFrame) {
      case 'Black Frame':
        frameDecoration = BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF1F1F1F), width: 8),
        );
        framePadding = const EdgeInsets.all(16);
        break;

      case 'Canvas':
        frameDecoration = BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(
              color: Colors.black.withValues(alpha: 0.6),
              width: 6,
            ),
            bottom: BorderSide(
              color: Colors.black.withValues(alpha: 0.6),
              width: 6,
            ),
          ),
        );
        framePadding = const EdgeInsets.all(0);
        break;

      case 'Posters':
      default:
        frameDecoration = const BoxDecoration(color: Colors.white);
        framePadding = const EdgeInsets.all(0);
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: frameDecoration,
      padding: framePadding,
      child: Container(
        color: Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Raw design print graphic
            widget.imageUrl.startsWith('http')
                ? Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  )
                : Image.asset(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
                  ),

            // Subtle glass glare effect on framed items
            if (widget.selectedFrame == 'Black Frame')
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.18),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.05),
                      ],
                      stops: const [0.0, 0.35, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

            // Canvas texture overlay
            if (widget.selectedFrame == 'Canvas')
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.02),
                  // In a real app we'd add a repeating texture image here,
                  // but we'll use a subtle dark overlay to differentiate from poster
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── CUSTOM PAINTERS ─────────────────────────────────────────

/// Paints a single animated scanline sweeping vertically for a cyberpunk feel.
class _ScanlinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ScanlinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final y = progress * size.height;
    canvas.drawRect(Rect.fromLTWH(0, y - 1, size.width, 2), paint);
  }

  @override
  bool shouldRepaint(covariant _ScanlinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
