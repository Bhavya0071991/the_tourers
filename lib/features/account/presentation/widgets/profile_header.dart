import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback? onEditTap;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    final initials = name.isNotEmpty
        ? name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: textColor),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(color: surfaceColor, width: 3),
            ),
            child: Center(
              child: Text(
                initials.toUpperCase(),
                style: GoogleFonts.bebasNeue(
                  fontSize: 28,
                  color: surfaceColor,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            name.toUpperCase(),
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              color: surfaceColor,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: surfaceColor.withValues(alpha: 0.5),
            ),
          ),
          if (onEditTap != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: surfaceColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  'EDIT PROFILE',
                  style: GoogleFonts.spaceMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: surfaceColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
