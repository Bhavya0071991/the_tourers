import 'package:flutter/material.dart';
import '../../../../core/widgets/app_text.dart';

class AdminInfoCard extends StatelessWidget {
  final String title;
  final Widget content;

  const AdminInfoCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: textColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.spaceMono(
            title,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}
