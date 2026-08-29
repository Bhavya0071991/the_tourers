import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../order/models/order_model.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AdminCustomDesignViewer extends StatelessWidget {
  final OrderItem item;

  const AdminCustomDesignViewer({super.key, required this.item});

  void _downloadDesign(String url, String filename) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = filename;
    anchorElement.target = '_blank';
    anchorElement.click();
  }

  void _showLightbox(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: AppImage(imageUrl: imageUrl, fit: BoxFit.contain),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showItemDetails(BuildContext context, Color textColor) {
    showDialog(
      context: context,
      builder: (context) {
        int currentImageIndex = 0;
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Container(
                width: 600,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: AppText.bebas(
                            item.name,
                            fontSize: 24,
                            letterSpacing: 1.5,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: textColor),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (item.images.isNotEmpty)
                      SizedBox(
                        height: 400,
                        child: Row(
                          children: [
                            if (item.images.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_back_ios,
                                  color: textColor,
                                  size: 16,
                                ),
                                onPressed: currentImageIndex > 0
                                    ? () => setState(() => currentImageIndex--)
                                    : null,
                              ),
                            Expanded(
                              child: Container(
                                color: textColor.withValues(alpha: 0.05),
                                child: GestureDetector(
                                  onTap: () => _showLightbox(
                                    context,
                                    item.images[currentImageIndex],
                                  ),
                                  child:
                                      item.images[currentImageIndex].startsWith(
                                        'assets/',
                                      )
                                      ? Image.asset(
                                          item.images[currentImageIndex],
                                          fit: BoxFit.contain,
                                        )
                                      : AppImage(
                                          imageUrl:
                                              item.images[currentImageIndex],
                                          fit: BoxFit.contain,
                                        ),
                                ),
                              ),
                            ),
                            if (item.images.length > 1)
                              IconButton(
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  color: textColor,
                                  size: 16,
                                ),
                                onPressed:
                                    currentImageIndex < item.images.length - 1
                                    ? () => setState(() => currentImageIndex++)
                                    : null,
                              ),
                          ],
                        ),
                      )
                    else if (item.imageUrl != null)
                      Container(
                        height: 400,
                        width: double.infinity,
                        color: textColor.withValues(alpha: 0.05),
                        child: GestureDetector(
                          onTap: () => _showLightbox(context, item.imageUrl!),
                          child: item.imageUrl!.startsWith('assets/')
                              ? Image.asset(item.imageUrl!, fit: BoxFit.contain)
                              : AppImage(
                                  imageUrl: item.imageUrl!,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    _detailRow('SIZE', item.size, textColor),
                    const SizedBox(height: 8),
                    _detailRow('QUANTITY', item.quantity.toString(), textColor),
                    const SizedBox(height: 8),
                    _detailRow(
                      'UNIT PRICE',
                      '₹${item.unitPrice.toStringAsFixed(0)}',
                      textColor,
                    ),
                    const SizedBox(height: 8),
                    _detailRow(
                      'TOTAL PRICE',
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      textColor,
                      isBold: true,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(
    String label,
    String value,
    Color textColor, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.spaceMono(
          label,
          fontSize: 12,
          color: textColor.withValues(alpha: 0.6),
        ),
        AppText.spaceMono(
          value,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final isCustom =
        item.frontDesignPreview != null ||
        item.frontPrintUrl != null ||
        item.backDesignPreview != null ||
        item.backPrintUrl != null;

    if (!isCustom) {
      return _buildNormalItem(context, textColor);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(border: Border.all(color: textColor, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.bebas(
                item.name,
                fontSize: 24,
                letterSpacing: 1.5,
                color: textColor,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                color: Colors.purple.withValues(alpha: 0.15),
                child: AppText.spaceMono(
                  AppStrings.adminCustomDesign,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText.spaceMono(
            '${AppStrings.adminSize} ${item.size}  |  ${AppStrings.adminQty} ${item.quantity}',
            fontSize: 12,
            color: textColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Mockup View
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.spaceMono(
                      AppStrings.adminMockup,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 500,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.05),
                        border: Border.all(
                          color: textColor.withValues(alpha: 0.2),
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
                              ),
                            )
                          else if (item.imageUrl != null)
                            Positioned.fill(
                              child: item.imageUrl!.startsWith('assets/')
                                  ? Image.asset(
                                      item.imageUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : AppImage(
                                      imageUrl: item.imageUrl!,
                                      fit: BoxFit.cover,
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
                  ],
                ),
              ),
              const SizedBox(width: 32),

              // 2. Raw Print File
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.spaceMono(
                      AppStrings.adminRawFile,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 500,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.05),
                        border: Border.all(
                          color: textColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: item.frontPrintUrl != null
                          ? GestureDetector(
                              onTap: () =>
                                  _showLightbox(context, item.frontPrintUrl!),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    AppImage(
                                      imageUrl: item.frontPrintUrl!,
                                      fit: BoxFit.contain,
                                      memCacheWidth: 600,
                                    ),
                                    Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      child: const Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Center(child: Text(AppStrings.adminNoFrontDesign)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text(AppStrings.adminDownloadFile),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: textColor,
                          foregroundColor: Theme.of(
                            context,
                          ).scaffoldBackgroundColor,
                        ),
                        onPressed: () {
                          if (item.frontPrintUrl != null) {
                            _downloadDesign(
                              item.frontPrintUrl!,
                              'custom_design_${item.name}.png',
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (item.customText != null && item.customText!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: textColor.withValues(alpha: 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.spaceMono(
                    AppStrings.adminCustomTextNotes,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 8),
                  AppText.spaceMono(
                    item.customText!,
                    fontSize: 14,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNormalItem(BuildContext context, Color textColor) {
    return InkWell(
      onTap: () => _showItemDetails(context, textColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: textColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: textColor.withValues(alpha: 0.05),
              child: item.imageUrl != null
                  ? GestureDetector(
                      onTap: () => _showLightbox(context, item.imageUrl!),
                      child: item.imageUrl!.startsWith('assets/')
                          ? Image.asset(item.imageUrl!, fit: BoxFit.contain)
                          : AppImage(
                              imageUrl: item.imageUrl!,
                              fit: BoxFit.contain,
                            ),
                    )
                  : const Icon(Icons.image),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bebas(
                    item.name,
                    fontSize: 18,
                    letterSpacing: 1.0,
                    color: textColor,
                  ),
                  const SizedBox(height: 4),
                  AppText.spaceMono(
                    '${AppStrings.adminSize} ${item.size}  |  ${AppStrings.adminQty} ${item.quantity}',
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
            AppText.spaceMono(
              '₹${item.totalPrice.toStringAsFixed(0)}',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ],
        ),
      ),
    );
  }
}
