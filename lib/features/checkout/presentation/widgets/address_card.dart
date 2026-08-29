import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/address_model.dart';

class AddressCard extends StatelessWidget {
  final Address address;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? textColor : Colors.transparent,
          border: Border.all(
            color: textColor,
            width: isSelected ? 3.0 : 2.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? surfaceColor : textColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 14, color: surfaceColor)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address.fullName,
                    style: GoogleFonts.spaceMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? surfaceColor : textColor,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    color: isSelected
                        ? surfaceColor
                        : textColor,
                    child: Text(
                      'DEFAULT',
                      style: GoogleFonts.spaceMono(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? textColor : surfaceColor,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Address body
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.addressLine,
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      color: (isSelected ? surfaceColor : textColor)
                          .withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                  ),
                  if (address.landmark.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      address.landmark,
                      style: GoogleFonts.spaceMono(
                        fontSize: 11,
                        color: (isSelected ? surfaceColor : textColor)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '${address.city}, ${address.state} - ${address.pincode}',
                    style: GoogleFonts.spaceMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: (isSelected ? surfaceColor : textColor)
                          .withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phone,
                    style: GoogleFonts.spaceMono(
                      fontSize: 11,
                      color: (isSelected ? surfaceColor : textColor)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            // Action buttons
            if (showActions) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Row(
                  children: [
                    if (onEdit != null)
                      _ActionButton(
                        label: 'EDIT',
                        icon: Icons.edit_outlined,
                        onTap: onEdit!,
                        color: isSelected ? surfaceColor : textColor,
                      ),
                    if (onEdit != null && onDelete != null)
                      const SizedBox(width: 16),
                    if (onDelete != null)
                      _ActionButton(
                        label: 'DELETE',
                        icon: Icons.delete_outline,
                        onTap: onDelete!,
                        color: Colors.redAccent,
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
