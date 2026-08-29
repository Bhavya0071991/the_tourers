import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class WebConstrainedBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const WebConstrainedBox({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxWebWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
