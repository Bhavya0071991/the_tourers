import 'package:flutter/material.dart';
import '../../../../core/widgets/app_image.dart';

class MockupImageWidget extends StatelessWidget {
  final String image;
  final String? mockup;
  final BoxFit fit;

  const MockupImageWidget({
    super.key,
    required this.image,
    this.mockup,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (mockup == null) {
      return AppImage(
        imageUrl: image,
        fit: fit,
        alignment: Alignment.topCenter,
        memCacheWidth: 800, // Optimize memory usage
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: AppImage(
            imageUrl: mockup!,
            fit: fit,
            alignment: Alignment.topCenter,
            memCacheWidth: 800,
          ),
        ),
        Positioned.fill(
          child: FractionallySizedBox(
            widthFactor: 0.29,
            heightFactor: 0.39,
            alignment: const Alignment(0, 0.05), // Moved lower, smaller size
            child: AppImage(
              imageUrl: image,
              fit: BoxFit.contain,
              memCacheWidth: 400,
              // We could theoretically disable the skeleton loader for the inner print here
              // by passing a custom errorWidget or placeholder to AppImage, but default is fine.
            ),
          ),
        ),
      ],
    );
  }
}
