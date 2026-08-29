import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../providers/admin_orders_provider.dart';
import '../../../order/models/order_model.dart';
import '../widgets/admin_custom_design_viewer.dart';
import '../widgets/admin_info_card.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/app_image.dart';

class AdminOrderDetailsPage extends ConsumerWidget {
  final String orderId;

  const AdminOrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(adminOrderByIdProvider(orderId));
    final textColor = Theme.of(context).colorScheme.onSurface;

    return orderState.when(
      loading: () => Center(child: CircularProgressIndicator(color: textColor)),
      error: (e, st) => Center(child: Text('Error loading order: $e')),
      data: (order) {
        if (order == null) {
          return const Center(child: Text('Order Not Found'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Back Button
              Row(
                children: [
                  BrutalistHoverWidget(
                    child: InkWell(
                      onTap: () => context.pop(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: textColor, width: 2),
                        ),
                        child: Icon(Icons.arrow_back, color: textColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  AppText.bebas(
                    'ORDER #${order.id.substring(0, 8)}',
                    fontSize: 32,
                    letterSpacing: 2.0,
                    color: textColor,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: textColor, width: 2),
                      color: textColor,
                    ),
                    child: AppText.spaceMono(
                      order.statusLabel,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Items and Customer Info
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AdminInfoCard(
                          title: 'ORDER ITEMS',
                          content: Column(
                            children: order.items.map((item) {
                              return _buildOrderItem(context, item, textColor);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AdminInfoCard(
                          title: 'CUSTOMER INFORMATION',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                'Name',
                                order.shippingAddress.fullName,
                                textColor,
                              ),
                              _buildInfoRow(
                                'Phone',
                                order.shippingAddress.phone,
                                textColor,
                              ),
                              _buildInfoRow(
                                'Address',
                                order.shippingAddress.addressLine,
                                textColor,
                              ),
                              _buildInfoRow(
                                'City/State',
                                '${order.shippingAddress.city}, ${order.shippingAddress.state} ${order.shippingAddress.pincode}',
                                textColor,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Column: Summary and Status
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        AdminInfoCard(
                          title: 'PAYMENT SUMMARY',
                          content: Column(
                            children: [
                              _buildInfoRow(
                                'Subtotal',
                                '₹${order.total.toStringAsFixed(0)}',
                                textColor,
                              ),
                              _buildInfoRow(
                                'Shipping',
                                '₹${order.deliveryMethod.charge.toStringAsFixed(0)}',
                                textColor,
                              ),
                              const Divider(height: 32),
                              _buildInfoRow(
                                'Total',
                                '₹${order.total.toStringAsFixed(0)}',
                                textColor,
                                isBold: true,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: textColor.withValues(alpha: 0.1),
                                  border: Border.all(color: textColor),
                                ),
                                child: Column(
                                  children: [
                                    AppText.spaceMono(
                                      'PAYMENT METHOD',
                                      fontSize: 10,
                                      color: textColor.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(height: 4),
                                    AppText.spaceMono(
                                      order.paymentMethod,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AdminInfoCard(
                          title: 'UPDATE STATUS',
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusButton(
                                context,
                                'CONFIRM ORDER',
                                OrderStatus.processing,
                                order,
                                textColor,
                                ref,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusButton(
                                context,
                                'MARK SHIPPED',
                                OrderStatus.shipped,
                                order,
                                textColor,
                                ref,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusButton(
                                context,
                                'MARK DELIVERED',
                                OrderStatus.delivered,
                                order,
                                textColor,
                                ref,
                              ),
                              const SizedBox(height: 12),
                              _buildStatusButton(
                                context,
                                'CANCEL ORDER',
                                OrderStatus.cancelled,
                                order,
                                textColor,
                                ref,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderItem(
    BuildContext context,
    OrderItem item,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: textColor, width: 1)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: textColor.withValues(alpha: 0.2)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (item.frontDesignPreview != null &&
                    item.frontDesignPreview!.startsWith('http'))
                  Positioned.fill(
                    child: AppImage(
                      imageUrl: item.frontDesignPreview!,
                      fit: BoxFit.cover,
                    ),
                  )
                else if (item.imageUrl != null)
                  Positioned.fill(
                    child: item.imageUrl!.startsWith('assets/')
                        ? Image.asset(item.imageUrl!, fit: BoxFit.cover)
                        : AppImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
                  ),
                if (item.frontDesignPreview != null &&
                    !item.frontDesignPreview!.startsWith('http'))
                  Positioned.fill(
                    child: Image.memory(
                      base64Decode(item.frontDesignPreview!),
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.spaceMono(
                  item.name,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                const SizedBox(height: 8),
                AppText.spaceMono(
                  'Size: ${item.size} | Qty: ${item.quantity}',
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.7),
                ),

                const SizedBox(height: 8),
                AppText.spaceMono(
                  '₹${item.unitPrice.toStringAsFixed(0)}',
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                if (item.frontDesignPreview != null) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(24),
                            child: AdminCustomDesignViewer(item: item),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.design_services, size: 16),
                    label: AppText.spaceMono(
                      'VIEW DESIGN ASSETS',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      foregroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color textColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: AppText.spaceMono(
              label,
              fontSize: 12,
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          Expanded(
            child: AppText.spaceMono(
              value,
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    OrderStatus value,
    OrderModel order,
    Color textColor,
    WidgetRef ref, {
    bool isDestructive = false,
  }) {
    final isActive = order.status == value;
    final canUpdate =
        order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.delivered &&
        !isActive;

    return BrutalistHoverWidget(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isActive
                ? textColor
                : isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.transparent,
            foregroundColor: isActive
                ? Theme.of(context).scaffoldBackgroundColor
                : isDestructive
                ? Colors.red
                : textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(
                color: isDestructive ? Colors.red : textColor,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: (!canUpdate)
              ? null
              : () async {
                  // Show confirmation
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      title: AppText.bebas(
                        'UPDATE STATUS',
                        fontSize: 24,
                        color: textColor,
                      ),
                      content: AppText.spaceMono(
                        'Are you sure you want to change the order status to ${value.name.toUpperCase()}?',
                        color: textColor,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: AppText.spaceMono('CANCEL', color: textColor),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textColor,
                            foregroundColor: Theme.of(
                              context,
                            ).scaffoldBackgroundColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                          child: AppText.spaceMono(
                            'YES, CHANGE IT',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  ref
                      .read(adminOrderOperationsProvider.notifier)
                      .updateOrderStatus(order.id, value);
                },
          child: AppText.spaceMono(
            isActive ? '$label (CURRENT)' : label,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
