import 'package:dummy_epod/features/auth/providers/auth_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/router/app_paths.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../wishlist/providers/wishlist_provider.dart';
import '../../../review/providers/review_provider.dart';
import '../../domain/entities/product.dart';
import 'mockup_image_widget.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider).value;
    final isLoggedIn =
        authState != null &&
        authState.status == AuthStatus.authenticated &&
        authState.id != null;

    final wishlist = ref.watch(wishlistProvider).value ?? [];
    final isWishlisted =
        isLoggedIn &&
        (widget.product.isFavorite ||
            wishlist.any((item) => item.productId == widget.product.id));

    final reviewsAsync = ref.watch(productReviewsProvider(widget.product.id));

    return MouseRegion(
      onEnter: (e) {
        if (e.kind == PointerDeviceKind.mouse) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (e) {
        if (e.kind == PointerDeviceKind.mouse) {
          setState(() => _isHovered = false);
        }
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.push(AppPaths.product, extra: widget.product.toMap());
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Container with Quick Add Reveal & Wishlist Icon
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      children: [
                        ClipRect(
                          child: AnimatedScale(
                            scale: _isHovered ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: MockupImageWidget(
                                image: widget.product.image ?? '',
                                mockup: widget.product.mockup,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                      // Dark overlay for brutalist contrast on hover
                      AnimatedOpacity(
                        opacity: _isHovered ? 0.2 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(color: Colors.black),
                      ),

                      // Wishlist Icon (Top Right)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 20,
                            color: isWishlisted
                                ? Colors.redAccent
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            final authState = ref.read(authProvider).value;
                            if (authState == null ||
                                authState.status != AuthStatus.authenticated ||
                                authState.id == null) {
                              AppSnackBar.show(
                                context,
                                'SECURE ACCESS PROTOCOL REQUIRED: PLEASE LOGIN',
                              );
                              context.push(AppPaths.auth);
                              return;
                            }
                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(widget.product.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
                const SizedBox(height: 8),

                // Product Details
                AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(left: _isHovered ? 4.0 : 0.0),
                  child: Text(
                    widget.product.name,
                    style: GoogleFonts.spaceMono(
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.of(context).size.width > 900
                          ? 13
                          : 11,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),

                // Price Row
                AnimatedPadding(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(left: _isHovered ? 4.0 : 0.0),
                  child: Row(
                    children: [
                      Text(
                        widget.product.price,
                        style: GoogleFonts.spaceMono(
                          fontWeight: FontWeight.w700,
                          fontSize: MediaQuery.of(context).size.width > 900
                              ? 14
                              : 12,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      if (widget.product.originalPrice != null) ...[
                        const SizedBox(width: 6),
                        Text(
                          widget.product.originalPrice!,
                          style: GoogleFonts.spaceMono(
                            fontWeight: FontWeight.w400,
                            fontSize: MediaQuery.of(context).size.width > 900
                                ? 12
                                : 10,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
                      reviewsAsync.when(
                        data: (reviews) {
                          final double avgRating = reviews.isEmpty
                              ? 0.0
                              : reviews.fold(
                                      0.0,
                                      (sum, item) => sum + item.rating,
                                    ) /
                                    reviews.length;
                          return Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 12,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                avgRating.toStringAsFixed(1),
                                style: GoogleFonts.spaceMono(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox(
                          height: 10,
                          width: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
