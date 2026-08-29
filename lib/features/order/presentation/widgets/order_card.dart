import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/widgets/app_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../../review/presentation/widgets/write_review_sheet.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCard({super.key, required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final isAsset = firstItem?.imageUrl?.startsWith('assets/') ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: textColor, width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: textColor, width: 2)),
                color: textColor.withValues(alpha: 0.03),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (firstItem?.frontDesignPreview != null &&
                      firstItem!.frontDesignPreview!.startsWith('http'))
                    Positioned.fill(
                      child: AppImage(
                        imageUrl: firstItem.frontDesignPreview!,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        memCacheWidth: 300,
                      ),
                    )
                  else if (firstItem?.imageUrl != null)
                    Positioned.fill(
                      child: isAsset
                          ? Image.asset(
                              firstItem!.imageUrl!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : AppImage(
                              imageUrl: firstItem!.imageUrl!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              memCacheWidth: 300,
                            ),
                    )
                  else
                    Icon(
                      Icons.checkroom,
                      size: 32,
                      color: textColor.withValues(alpha: 0.2),
                    ),
                  if (firstItem?.frontDesignPreview != null &&
                      !firstItem!.frontDesignPreview!.startsWith('http'))
                    Positioned.fill(
                      child: Image.memory(
                        base64Decode(firstItem.frontDesignPreview!),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                ],
              ),
            ),

            // Order info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.id,
                            style: GoogleFonts.spaceMono(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                        _paymentBadge(order.paymentStatus, order.paymentMethod),
                        const SizedBox(width: 4),
                        _statusBadge(order.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      firstItem != null
                          ? '${firstItem.name}${order.items.length > 1 ? " +${order.items.length - 1} more" : ""}'
                          : 'Order',
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: textColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy').format(order.orderedAt),
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: textColor.withValues(alpha: 0.4),
                          ),
                        ),
                        Text(
                          '₹${order.total.toStringAsFixed(0)}',
                          style: GoogleFonts.spaceMono(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    if (firstItem != null) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          if (order.items.length > 1) {
                            // If multiple items, send them to the details page so they can review all of them
                            if (onTap != null) {
                              onTap!();
                            }
                          } else {
                            // If only 1 item, open the review sheet directly
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => WriteReviewSheet(
                                productId:
                                    firstItem.productId ??
                                    'custom_${firstItem.name.replaceAll(' ', '_')}',
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: textColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_border,
                                size: 14,
                                color: textColor.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.items.length > 1
                                    ? 'REVIEW ITEMS'
                                    : 'WRITE A REVIEW',
                                style: GoogleFonts.spaceMono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: textColor.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    Color badgeColor;
    switch (status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: badgeColor.withValues(alpha: 0.15),
      child: Text(
        status.name.toUpperCase(),
        style: GoogleFonts.spaceMono(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _paymentBadge(PaymentStatus status, String method) {
    Color badgeColor;
    String label;

    if (status == PaymentStatus.paid) {
      badgeColor = Colors.green;
      label = 'PAID';
    } else if (method == 'Cash on Delivery') {
      badgeColor = Colors.orange;
      label = 'COD';
    } else if (status == PaymentStatus.refunded) {
      badgeColor = Colors.purple;
      label = 'REFUNDED';
    } else {
      badgeColor = Colors.redAccent;
      label = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      color: badgeColor.withValues(alpha: 0.15),
      child: Text(
        label,
        style: GoogleFonts.spaceMono(
          fontSize: 8,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }
}
