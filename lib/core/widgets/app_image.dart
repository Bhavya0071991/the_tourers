import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'skeleton_loader.dart';

class AppImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.memCacheWidth,
    this.memCacheHeight,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.startsWith('data:image')) {
      // It's a Base64 encoded string from ImagePicker in dummy app
      final base64String = imageUrl.split(',').last;
      return Image.memory(
        base64Decode(base64String),
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        placeholder: (context, url) => SkeletonLoader(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
        ),
        errorWidget: (context, url, error) =>
            errorWidget ??
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    } else {
      // Fallback for local assets if provided
      return Image.asset(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        cacheWidth: memCacheWidth,
        cacheHeight: memCacheHeight,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ??
            const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
      );
    }
  }
}
