import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_paths.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_text.dart';
import '../../domain/entities/portrait_design.dart';

class PortraitCard extends StatefulWidget {
  final PortraitDesign design;

  const PortraitCard({super.key, required this.design});

  @override
  State<PortraitCard> createState() => _PortraitCardState();
}

class _PortraitCardState extends State<PortraitCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (e) {
        if (e.kind == PointerDeviceKind.mouse) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (e) {
        if (e.kind == PointerDeviceKind.mouse) {
          setState(() => _isHovered = false);
        }
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push(AppPaths.portraitDetails(widget.design.id));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Mockup Frame Showcase ───
                Expanded(
                  child: Stack(
                    children: [
                      // Print artwork with zoom effect
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedScale(
                          scale: _isHovered ? 1.06 : 1.0,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.onSurface,
                                width: 3,
                              ),
                            ),
                            child: widget.design.imageUrl.startsWith('http')
                                ? Image.network(
                                    widget.design.imageUrl,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderArt(theme),
                                  )
                                : Image.asset(
                                    widget.design.imageUrl,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.center,
                                    errorBuilder: (_, __, ___) =>
                                        _buildPlaceholderArt(theme),
                                  ),
                          ),
                        ),
                      ),

                      // Edition Number Badge (Top-Right) — premium touch
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.pureBlack.withValues(alpha: 0.85),
                            border: Border.all(
                              color: AppTheme.neonAccent.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'ED. ${widget.design.id.hashCode.abs() % 50 + 1}/50',
                            style: GoogleFonts.spaceMono(
                              color: AppTheme.neonAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),

                      // Category Tag (Bottom-Right)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          color: theme.colorScheme.onSurface,
                          child: Text(
                            widget.design.category.toUpperCase(),
                            style: GoogleFonts.spaceMono(
                              color: theme.colorScheme.surface,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ),

                      // Dark overlay for brutalist contrast on hover
                      AnimatedOpacity(
                        opacity: _isHovered ? 0.2 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(color: Colors.black),
                      ),

                      // Hover "VIEW" indicator (bottom-left, reveals on hover)
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: AnimatedOpacity(
                          opacity: _isHovered ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 250),
                          child: AnimatedSlide(
                            offset: _isHovered
                                ? Offset.zero
                                : const Offset(0, 0.3),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              color: AppTheme.neonAccent,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'VIEW PRINT',
                                    style: GoogleFonts.spaceMono(
                                      color: AppTheme.pureBlack,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 9,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 10,
                                    color: AppTheme.pureBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const SizedBox(height: 16),

                // Design name
                AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(left: _isHovered ? 6.0 : 0.0),
                  child: AppText.bebas(
                    widget.design.name,
                    fontSize: isDesktop ? 22 : 18,
                    letterSpacing: 1.5,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),

                // Designer credit
                AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(left: _isHovered ? 6.0 : 0.0),
                  child: Row(
                    children: [
                      AppText.spaceMono(
                        'BY ',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      AppText.spaceMono(
                        widget.design.designerName.toUpperCase(),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.neonAccent,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: AppTheme.neonAccent.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Price + Signature row
                AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(left: _isHovered ? 6.0 : 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.design.price,
                            style: GoogleFonts.spaceMono(
                              fontWeight: FontWeight.w700,
                              fontSize: isDesktop ? 16 : 14,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (widget.design.originalPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              widget.design.originalPrice!,
                              style: GoogleFonts.spaceMono(
                                fontWeight: FontWeight.w400,
                                fontSize: isDesktop ? 13 : 11,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.4,
                                ),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Cursive signature placeholder
                      Text(
                        'Pranxhu',
                        style: GoogleFonts.greatVibes(
                          fontSize: 18,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.45,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderArt(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.palette_outlined,
              size: 40,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 8),
            AppText.spaceMono(
              'ARTWORK',
              fontSize: 10,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}
