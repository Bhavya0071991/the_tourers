import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../widgets/order_timeline.dart';
import '../widgets/order_item_tile.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch the specific order by ID to prevent unnecessary rebuilds
    final order = ref.watch(orderProvider.select((state) {
      return state.value?.where((o) => o.id == orderId).firstOrNull;
    }));
    
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (order == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: textColor.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              AppText.bebas('ORDER NOT FOUND', fontSize: 24, color: textColor),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(AppPaths.orders),
                child: const Text('VIEW ALL ORDERS'),
              ),
            ],
          ),
        ),
      );
    }

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
                  Expanded(
                    child: AppText.bebas(
                      'ORDER ${order.id}',
                      fontSize: 18,
                      letterSpacing: 1.0,
                      color: textColor,
                    ),
                  ),
                  _statusBadge(order, textColor),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: textColor, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.spaceMono(
                            '/// ORDER DETAILS',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          _infoRow('ORDER ID', order.id, textColor),
                          const SizedBox(height: 8),
                          _infoRow(
                            'ORDERED ON',
                            DateFormat('dd MMM yyyy, hh:mm a')
                                .format(order.orderedAt),
                            textColor,
                          ),
                          const SizedBox(height: 8),
                          _infoRow(
                            'PAYMENT',
                            '${order.paymentMethod} — ${order.paymentStatusLabel}',
                            textColor,
                          ),
                          if (order.estimatedDelivery != null) ...[
                            const SizedBox(height: 8),
                            _infoRow(
                              'EST. DELIVERY',
                              DateFormat('dd MMM yyyy')
                                  .format(order.estimatedDelivery!),
                              textColor,
                            ),
                          ],
                          if (order.trackingUrl != null) ...[
                            const SizedBox(height: 16),
                            Divider(color: textColor.withValues(alpha: 0.1)),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText.spaceMono('TRACKING', fontSize: 10, color: textColor.withValues(alpha: 0.4)),
                                TextButton.icon(
                                  onPressed: () {
                                    // TODO: Open Tracking URL (url_launcher)
                                  },
                                  icon: const Icon(Icons.open_in_new, size: 14, color: Colors.blue),
                                  label: AppText.spaceMono('TRACK PACKAGE', fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
                                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tracking timeline
                    AppText.bebas(
                      'ORDER TRACKING',
                      fontSize: 24,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                    const SizedBox(height: 4),
                    AppText.spaceMono(
                      '/// SHIPMENT PROGRESS LOG',
                      fontSize: 10,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 20),
                    OrderTimeline(events: order.timeline),

                    const SizedBox(height: 32),

                    // Ordered items
                    AppText.bebas(
                      'ORDERED ITEMS',
                      fontSize: 24,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                    const SizedBox(height: 4),
                    AppText.spaceMono(
                      '/// ${order.items.length} ITEM${order.items.length > 1 ? "S" : ""} IN THIS ORDER',
                      fontSize: 10,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 16),
                    ...order.items.map((item) => OrderItemTile(item: item)),

                    const SizedBox(height: 32),

                    // Shipping address
                    AppText.bebas(
                      'SHIPPING ADDRESS',
                      fontSize: 24,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: textColor.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText.spaceMono(
                            order.shippingAddress.fullName,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          const SizedBox(height: 6),
                          AppText.spaceMono(
                            order.shippingAddress.formattedAddress,
                            fontSize: 11,
                            color: textColor.withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                          const SizedBox(height: 4),
                          AppText.spaceMono(
                            order.shippingAddress.phone,
                            fontSize: 11,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Price breakdown
                    AppText.bebas(
                      'PAYMENT SUMMARY',
                      fontSize: 24,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.03),
                        border: Border.all(color: textColor, width: 2),
                      ),
                      child: Column(
                        children: [
                          _priceRow('SUBTOTAL', '₹${order.subtotal.toStringAsFixed(0)}', textColor),
                          if (order.discount > 0) ...[
                            const SizedBox(height: 8),
                            _priceRow('DISCOUNT', '-₹${order.discount.toStringAsFixed(0)}', Colors.redAccent),
                          ],
                          const SizedBox(height: 8),
                          _priceRow(
                            'DELIVERY',
                            order.deliveryCharge == 0
                                ? 'FREE'
                                : '₹${order.deliveryCharge.toStringAsFixed(0)}',
                            textColor,
                          ),
                          const SizedBox(height: 8),
                          _priceRow('GST', '₹${order.gst.toStringAsFixed(0)}', textColor),
                          const SizedBox(height: 12),
                          Divider(color: textColor, thickness: 2),
                          const SizedBox(height: 12),
                          _priceRow(
                            'TOTAL',
                            '₹${order.total.toStringAsFixed(0)}',
                            textColor,
                            isBold: true,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Support section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: textColor.withValues(alpha: 0.15),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.headset_mic_outlined,
                            size: 28,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          AppText.spaceMono(
                            'NEED HELP WITH THIS ORDER?',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 4),
                          AppText.spaceMono(
                            'support@thetourers.com',
                            fontSize: 10,
                            color: textColor.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Reorder button
                    BrutalistHoverWidget(
                      shadowColor: textColor.withValues(alpha: 0.15),
                      offset: const Offset(4, 4),
                      child: SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.go(AppPaths.home),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textColor,
                            side: BorderSide(color: textColor, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: AppText.bebas(
                            'REORDER SIMILAR ITEMS',
                            fontSize: 16,
                            letterSpacing: 1.5,
                            color: textColor,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(OrderModel order, Color textColor) {
    Color badgeColor;
    switch (order.status) {
      case OrderStatus.processing:
        badgeColor = Colors.amber;
      case OrderStatus.shipped:
        badgeColor = Colors.blue;
      case OrderStatus.outForDelivery:
        badgeColor = Colors.orange;
      case OrderStatus.delivered:
        badgeColor = Colors.green;
      case OrderStatus.cancelled:
        badgeColor = Colors.redAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: badgeColor.withValues(alpha: 0.15),
      child: AppText.spaceMono(
        order.statusLabel,
        fontSize: 9,
        fontWeight: FontWeight.bold,
        color: badgeColor,
      ),
    );
  }

  Widget _infoRow(String label, String value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: AppText.spaceMono(
            label,
            fontSize: 10,
            color: textColor.withValues(alpha: 0.4),
          ),
        ),
        Expanded(
          child: AppText.spaceMono(
            value,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ],
    );
  }

  Widget _priceRow(
    String label,
    String value,
    Color color, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.spaceMono(
          label,
          fontSize: fontSize - 1,
          color: color.withValues(alpha: isBold ? 1.0 : 0.6),
        ),
        AppText.spaceMono(
          value,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          color: color,
        ),
      ],
    );
  }
}
