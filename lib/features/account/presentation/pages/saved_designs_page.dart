import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class SavedDesignsPage extends ConsumerWidget {
  const SavedDesignsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: textColor.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  AppText.bebas(
                    'SAVED AI DESIGNS',
                    fontSize: 22,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ],
              ),
            ),

            // Empty state
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        size: 56,
                        color: textColor.withValues(alpha: 0.15),
                      ),
                      const SizedBox(height: 20),
                      AppText.bebas(
                        'NO SAVED DESIGNS',
                        fontSize: 24,
                        color: textColor,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      AppText.spaceMono(
                        'Create custom T-shirt designs\nwith our AI generator and\nsave them here.',
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.4),
                        textAlign: TextAlign.center,
                        height: 1.6,
                      ),
                      const SizedBox(height: 32),
                      BrutalistHoverWidget(
                        shadowColor: textColor.withValues(alpha: 0.15),
                        offset: const Offset(4, 4),
                        child: ElevatedButton(
                          onPressed: () => context.go(AppPaths.generator),
                          child: AppText.bebas(
                            'START CREATING ↗',
                            fontSize: 16,
                            letterSpacing: 1.5,
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
      ),
    );
  }
}
