import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../../../core/router/app_router.dart';
import '../../../review/presentation/widgets/write_review_sheet.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: textColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // Always navigate to product details
              String displayImage = '';
              if (item.frontDesignPreview != null &&
                  item.frontDesignPreview!.startsWith('http')) {
                displayImage = item.frontDesignPreview!;
              } else if (item.imageUrl != null) {
                displayImage = item.imageUrl!;
              }

              final productMap = {
                'id':
                    item.productId ??
                    'custom_${DateTime.now().millisecondsSinceEpoch}',
                'name': item.name,
                'price': '₹${item.unitPrice}',
                'image': displayImage,
                'images': item.images.join('||'),
                'description':
                    item.customText ??
                    'Custom generated product from your order history.',
                'tag': item.tag ?? 'CUSTOM',
                'gender': 'unisex',
                'category': 't-shirts',
              };

              context.pushNamed(AppRoute.product.name, extra: productMap);
            },
            child: Container(
              width: 64,
              height: 72,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.03),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.1),
                  width: 1,
                ),
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
                        memCacheWidth: 200,
                      ),
                    )
                  else if (item.imageUrl != null)
                    Positioned.fill(
                      child: item.imageUrl!.startsWith('assets/')
                          ? Image.asset(item.imageUrl!, fit: BoxFit.cover)
                          : AppImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.cover,
                              memCacheWidth: 200,
                            ),
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
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.spaceMono(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      color: textColor.withValues(alpha: 0.08),
                      child: Text(
                        'SIZE: ${item.size}',
                        style: GoogleFonts.spaceMono(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'QTY: ${item.quantity}',
                      style: GoogleFonts.spaceMono(
                        fontSize: 9,
                        color: textColor.withValues(alpha: 0.5),
                      ),
                    ),
                    if (item.tag != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        color: textColor,
                        child: Text(
                          item.tag!,
                          style: GoogleFonts.spaceMono(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${item.totalPrice.toStringAsFixed(0)}',
                  style: GoogleFonts.spaceMono(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => WriteReviewSheet(
                        productId: item.productId ?? 'custom_${item.name.replaceAll(' ', '_')}',
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: textColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_border, size: 14, color: textColor.withValues(alpha: 0.6)),
                        const SizedBox(width: 4),
                        Text(
                          'WRITE A REVIEW',
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
            ),
          ),
        ],
      ),
    );
  }
}
