import 'package:flutter/material.dart';
import 'app_image.dart';

class ImageCard extends StatelessWidget {
  final String imageUrl;
  final double height;
  final Widget? overlayContent;

  const ImageCard({
    super.key,
    required this.imageUrl,
    this.height = 400.0,
    this.overlayContent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            memCacheWidth: 600,
          ),
          ?overlayContent,
        ],
      ),
    );
  }
}
