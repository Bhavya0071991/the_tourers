import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final bool showDivider;
  final Widget? trailing;

  const AccountMenuTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.iconColor,
    this.showDivider = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (iconColor ?? textColor).withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? textColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: GoogleFonts.spaceMono(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: iconColor ?? textColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: textColor.withValues(alpha: 0.3),
                    ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: textColor.withValues(alpha: 0.06),
            indent: 80,
          ),
      ],
    );
  }
}
