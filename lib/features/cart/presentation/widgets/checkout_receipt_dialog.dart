import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/cart_provider.dart';
import '../../models/cart_item.dart';

class CheckoutReceiptDialog extends ConsumerWidget {
  final List<CartItem> cartItems;
  final double subtotal;
  final String username;
  final double discountPercentage;

  const CheckoutReceiptDialog({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.username,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final discountAmount = subtotal * discountPercentage;
    final shipping = subtotal > 5000 ? 0.0 : 150.0;
    final finalTotal = subtotal - discountAmount + shipping;
    final txnId =
        'TXN_2026_${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 40.0,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          decoration: BoxDecoration(
            color: textColor, // Inverted for brutal contrast
            border: Border.all(color: textColor, width: 4.0),
          ),
          padding: const EdgeInsets.all(28.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Receipt Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.bebas(
                      AppStrings.invoiceTitle,
                      fontSize: 32,
                      color: surfaceColor,
                      letterSpacing: 2.0,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: Colors.greenAccent,
                      child: AppText.spaceMono(
                        AppStrings.paidCompleted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Divider(
                  color: surfaceColor.withValues(alpha: 0.3),
                  thickness: 1.5,
                ),
                const SizedBox(height: 16),

                AppText.spaceMono(
                  'STATION_ID: // THE_TOURERS_HQ\nOPERATOR: // $username\nTRANSACTION_ID: // $txnId\nTIMESTAMP: // ${DateTime.now().toLocal().toString().substring(0, 19)}',
                  fontSize: 11,
                  color: surfaceColor.withValues(alpha: 0.7),
                  height: 1.6,
                ),

                const SizedBox(height: 24),
                AppText.spaceMono(
                  AppStrings.itemsDispatched,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: surfaceColor,
                ),
                const SizedBox(height: 8),

                // Items list
                ...cartItems.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.spaceMono(
                          '${item.quantity}x ',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                        if (item.frontDesignPreview != null) ...[
                          Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12, left: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: surfaceColor.withValues(alpha: 0.3), width: 1.5),
                              color: surfaceColor.withValues(alpha: 0.05),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: (item.frontDesignPreview != null && item.frontDesignPreview!.startsWith('http'))
                                      ? AppImage(
                                          imageUrl: item.frontDesignPreview!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          item.product['image'] ?? 'assets/images/plain_black_tee.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                if (item.frontDesignPreview != null && !item.frontDesignPreview!.startsWith('http'))
                                  Positioned.fill(
                                    child: Image.memory(
                                      base64Decode(item.frontDesignPreview!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.spaceMono(
                                item.product['name'] ?? '',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: surfaceColor,
                              ),
                              AppText.spaceMono(
                                '${AppStrings.sizeLabel} ${item.size} ${item.customText != null ? " | CONFIG: ${item.customText!}" : ""}',
                                fontSize: 9,
                                color: surfaceColor.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        AppText.spaceMono(
                          '₹${item.totalPrice.toStringAsFixed(0)}',
                          fontSize: 12,
                          color: surfaceColor,
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Divider(
                  color: surfaceColor.withValues(alpha: 0.2),
                  thickness: 1.0,
                ),
                const SizedBox(height: 16),

                // Calculations
                _buildReceiptRow(
                  AppStrings.subtotalRow,
                  '₹${subtotal.toStringAsFixed(0)}',
                  surfaceColor,
                ),
                if (discountPercentage > 0)
                  _buildReceiptRow(
                    '${AppStrings.promoDiscountRow} (${(discountPercentage * 100).toStringAsFixed(0)}%)',
                    '-₹${discountAmount.toStringAsFixed(0)}',
                    Colors.redAccent,
                  ),
                _buildReceiptRow(
                  AppStrings.shippingRow,
                  shipping == 0
                      ? AppStrings.freeShipping
                      : '₹${shipping.toStringAsFixed(0)}',
                  surfaceColor,
                ),

                const SizedBox(height: 12),
                Divider(color: surfaceColor, thickness: 2.0),
                const SizedBox(height: 12),

                _buildReceiptRow(
                  AppStrings.grandTotalRow,
                  '₹${finalTotal.toStringAsFixed(0)}',
                  surfaceColor,
                  isBold: true,
                  fontSize: 18,
                ),

                const SizedBox(height: 32),
                AppText.spaceMono(
                  AppStrings.shipmentNotice,
                  fontSize: 8,
                  color: surfaceColor.withValues(alpha: 0.4),
                  height: 1.5,
                ),
                const SizedBox(height: 24),

                // Close receipt button
                BrutalistHoverWidget(
                  shadowColor: surfaceColor.withValues(alpha: 0.3),
                  offset: const Offset(4, 4),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(cartProvider.notifier).clearCart();
                        context.go(AppPaths.home);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: surfaceColor,
                        foregroundColor: textColor,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: AppText.bebas(
                        AppStrings.confirmCloseBtn,
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(
    String title,
    String val,
    Color color, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText.spaceMono(
            title,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
          AppText.spaceMono(
            val,
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ],
      ),
    );
  }
}
