import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderSummarySection extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double gst;
  final double total;
  final double discountPercentage;

  const OrderSummarySection({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.gst,
    required this.total,
    this.discountPercentage = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.03),
        border: Border.all(color: textColor, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '/// ORDER SUMMARY',
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 16),

          _row('SUBTOTAL', '₹${subtotal.toStringAsFixed(0)}', textColor),
          const SizedBox(height: 8),

          if (discount > 0) ...[
            _row(
              'DISCOUNT (${(discountPercentage * 100).toStringAsFixed(0)}%)',
              '-₹${discount.toStringAsFixed(0)}',
              Colors.redAccent,
            ),
            const SizedBox(height: 8),
          ],

          _row(
            'DELIVERY',
            deliveryCharge == 0
                ? 'FREE'
                : '₹${deliveryCharge.toStringAsFixed(0)}',
            textColor,
          ),
          const SizedBox(height: 8),

          _row('GST (18%)', '₹${gst.toStringAsFixed(0)}', textColor),
          const SizedBox(height: 12),

          Divider(color: textColor, thickness: 2),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'GRAND TOTAL',
                style: GoogleFonts.spaceMono(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: GoogleFonts.bebasNeue(
                  fontSize: 28,
                  color: textColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 11,
            color: color.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
