import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/animated_check_icon.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/fade_in_slide_widget.dart';
import '../../providers/order_provider.dart';
import '../../../../core/theme/app_theme.dart';

class OrderSuccessPage extends ConsumerWidget {
  const OrderSuccessPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderId = ref.watch(lastPlacedOrderIdProvider);
    final order = ref.watch(orderProvider.select((state) {
      if (orderId == null) return null;
      return state.value?.where((o) => o.id == orderId).firstOrNull;
    }));
    final textColor = Theme.of(context).colorScheme.onSurface;

    final estimatedDate = order?.estimatedDelivery != null
        ? DateFormat('dd MMM yyyy').format(order!.estimatedDelivery!)
        : 'In 5-7 business days';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(AppPaths.home);
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),

                    // Success animation
                    AnimatedCheckIcon(
                      size: 120,
                      color: AppTheme.pureBlack,
                      backgroundColor: AppTheme.neonAccent,
                      delay: const Duration(milliseconds: 300),
                    ),

                    const SizedBox(height: 40),

                    // Success text
                    FadeInSlideWidget(
                      delay: const Duration(milliseconds: 800),
                      child: Column(
                        children: [
                          AppText.bebas(
                            'ORDER CONFIRMED',
                            fontSize: 42,
                            letterSpacing: 2,
                            color: textColor,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          AppText.spaceMono(
                            '/// TRANSACTION COMPLETED SUCCESSFULLY',
                            fontSize: 10,
                            color: textColor.withValues(alpha: 0.4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Order details card
                    FadeInSlideWidget(
                      delay: const Duration(milliseconds: 1200),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: textColor, width: 2.5),
                        ),
                        child: Column(
                          children: [
                            _infoRow(
                              'ORDER ID',
                              orderId ?? 'ORD_XXXXXXXX',
                              textColor,
                              isBold: true,
                            ),
                            const SizedBox(height: 16),
                            Divider(
                              color: textColor.withValues(alpha: 0.1),
                              thickness: 1,
                            ),
                            const SizedBox(height: 16),
                            _infoRow(
                              'ESTIMATED DELIVERY',
                              estimatedDate,
                              textColor,
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              'PAYMENT STATUS',
                              order?.paymentStatusLabel ?? 'PAID',
                              textColor,
                            ),
                            const SizedBox(height: 12),
                            _infoRow(
                              'TOTAL PAID',
                              order != null
                                  ? '₹${order.total.toStringAsFixed(0)}'
                                  : '—',
                              textColor,
                            ),
                            if (order?.items != null) ...[
                              const SizedBox(height: 12),
                              _infoRow(
                                'ITEMS',
                                '${order!.totalItemCount} item${order.totalItemCount > 1 ? "s" : ""}',
                                textColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Thank you message
                    FadeInSlideWidget(
                      delay: const Duration(milliseconds: 1500),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: textColor.withValues(alpha: 0.04),
                        child: AppText.spaceMono(
                          'Thank you for shopping with THE TOURERS.\nYour streetwear capsule is being curated.',
                          fontSize: 10,
                          color: textColor.withValues(alpha: 0.5),
                          textAlign: TextAlign.center,
                          height: 1.6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Action buttons
                    FadeInSlideWidget(
                      delay: const Duration(milliseconds: 1800),
                      child: Column(
                        children: [
                          BrutalistHoverWidget(
                            shadowColor: textColor.withValues(alpha: 0.2),
                            offset: const Offset(5, 5),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.go(AppPaths.orders),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.neonAccent,
                                  foregroundColor: AppTheme.pureBlack,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                    side: const BorderSide(
                                      color: AppTheme.pureBlack,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: AppText.bebas(
                                  'VIEW MY ORDERS ↗',
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          BrutalistHoverWidget(
                            shadowColor: textColor.withValues(alpha: 0.1),
                            offset: const Offset(4, 4),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => context.go(AppPaths.home),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textColor,
                                  side: BorderSide(color: textColor, width: 2),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                ),
                                child: AppText.bebas(
                                  'CONTINUE SHOPPING',
                                  fontSize: 18,
                                  letterSpacing: 1.5,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.spaceMono(
          label,
          fontSize: 10,
          color: color.withValues(alpha: 0.5),
        ),
        Flexible(
          child: AppText.spaceMono(
            value,
            fontSize: isBold ? 13 : 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
