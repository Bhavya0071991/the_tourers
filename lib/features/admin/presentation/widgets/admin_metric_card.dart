import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class AdminMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const AdminMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return BrutalistHoverWidget(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: textColor, width: 2),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.spaceMono(
                title,
                fontSize: 12,
                color: textColor.withValues(alpha: 0.6),
              ),
              Icon(icon, color: textColor.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: 16),
          AppText.bebas(
            value,
            fontSize: 32,
            letterSpacing: 1.0,
            color: textColor,
          ),
        ],
      ),
      ),
    );
  }
}
