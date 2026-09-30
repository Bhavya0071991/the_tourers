import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../order/models/order_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminCustomDesignViewer extends StatelessWidget {
  final OrderItem item;

  const AdminCustomDesignViewer({super.key, required this.item});

  Future<void> _downloadDesign(String url, String filename) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final bgColor = Theme.of(context).colorScheme.surface;

    return Material(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: textColor, width: 2),
      ),
      child: SizedBox(
        width: 800,
        height: 700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: textColor, width: 2)),
                color: AppTheme.neonAccent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bebas(
                          'DESIGN ASSETS: ${item.name}',
                          fontSize: 24,
                          letterSpacing: 1.5,
                          color: AppTheme.pureBlack,
                        ),
                        const SizedBox(height: 4),
                        AppText.spaceMono(
                          '${AppStrings.adminSize} ${item.size}  |  ${AppStrings.adminQty} ${item.quantity}',
                          fontSize: 12,
                          color: AppTheme.pureBlack.withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.pureBlack),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.customText != null &&
                        item.customText!.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: textColor.withValues(alpha: 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.spaceMono(
                              'CUSTOM TEXT NOTES:',
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
                      const SizedBox(height: 32),
                    ],

                    // Front Print Section
                    if (item.frontDesignPreview != null ||
                        item.frontPrintUrl != null) ...[
                      _buildDesignSection(
                        context,
                        title: 'FRONT PRINT',
                        previewUrl: item.frontDesignPreview,
                        printUrl: item.frontPrintUrl,
                        textColor: textColor,
                      ),
                      const SizedBox(height: 48),
                    ],

                    // Back Print Section
                    if (item.backDesignPreview != null ||
                        item.backPrintUrl != null) ...[
                      _buildDesignSection(
                        context,
                        title: 'BACK PRINT',
                        previewUrl: item.backDesignPreview,
                        printUrl: item.backPrintUrl,
                        textColor: textColor,
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

  Widget _buildDesignSection(
    BuildContext context, {
    required String title,
    required String? previewUrl,
    required String? printUrl,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bebas(
          title,
          fontSize: 24,
          letterSpacing: 1.5,
          color: textColor,
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mockup View
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.spaceMono(
                    'MOCKUP PREVIEW',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.05),
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: previewUrl != null
                        ? (previewUrl.startsWith('http') ||
                                  previewUrl.startsWith('assets/')
                              ? AppImage(
                                  imageUrl: previewUrl,
                                  fit: BoxFit.contain,
                                )
                              : Image.memory(
                                  base64Decode(previewUrl),
                                  fit: BoxFit.contain,
                                ))
                        : Center(
                            child: Text(
                              'NO PREVIEW',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            // Raw Print File
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.spaceMono(
                    'RAW PRINT FILE (DTF)',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 340,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.05),
                      border: Border.all(
                        color: textColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: printUrl != null
                        ? GestureDetector(
                            onTap: () => _showLightbox(context, printUrl),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AppImage(
                                    imageUrl: printUrl,
                                    fit: BoxFit.contain,
                                  ),
                                  Container(
                                    color: Colors.black.withValues(alpha: 0.3),
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
                        : Center(
                            child: Text(
                              'NO RAW FILE',
                              style: TextStyle(
                                color: textColor.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('DOWNLOAD PRINT FILE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                      onPressed: printUrl != null
                          ? () {
                              _downloadDesign(
                                printUrl,
                                'custom_design_${title.toLowerCase().replaceAll(' ', '_')}.png',
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
