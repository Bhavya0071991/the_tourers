import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import '../../../../core/widgets/app_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../home/presentation/widgets/footer_section.dart';
import '../../../home/presentation/widgets/promo_banner.dart';
import '../../providers/cart_provider.dart';
import '../../providers/cart_view_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../checkout/providers/checkout_provider.dart';
import '../../models/cart_item.dart';
import '../../../../core/theme/app_theme.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromoCode() {
    final result = ref.read(cartViewModelProvider.notifier).applyPromoCode(_promoController.text);
    AppSnackBar.show(context, result);
  }

  void _removePromoCode() {
    final result = ref.read(cartViewModelProvider.notifier).removePromoCode();
    _promoController.clear();
    AppSnackBar.show(context, result);
  }

  void _handleCheckout(double discountPercentage) {
    final authState = ref.read(authProvider);

    if (authState.value?.status != AuthStatus.authenticated) {
      AppSnackBar.show(
        context,
        'SECURE ACCESS PROTOCOL REQUIRED: PLEASE LOGIN',
      );
      context.push(AppPaths.auth);
      return;
    }

    // Store discount in checkout provider for the payment flow
    if (discountPercentage > 0) {
      ref.read(checkoutProvider.notifier).setDiscount(discountPercentage);
    }

    // Navigate to multi-step checkout
    context.push(AppPaths.checkoutAddress);
  }

  @override
  Widget build(BuildContext context) {
    final cartItemsAsync = ref.watch(cartProvider);
    final subtotal = ref.watch(cartTotalPriceProvider);
    final count = ref.watch(cartItemCountProvider);
    final cartViewState = ref.watch(cartViewModelProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    // Pricing formulas
    final discountAmount = subtotal * cartViewState.discountPercentage;
    final shipping = subtotal > 5000 || subtotal == 0 ? 0.0 : 150.0;
    final total = subtotal - discountAmount + shipping;

    return Scaffold(
      body: Column(
        children: [
          const PromoBanner(),
          const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  WebConstrainedBox(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 64.0 : 16.0,
                      vertical: isDesktop ? 48.0 : 32.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Giant Header
                        AppText.bebas(
                          'YOUR SHOPPING BAG',
                          fontSize: isDesktop ? 80 : 42,
                          height: 0.9,
                          letterSpacing: 2.0,
                          color: textColor,
                        ),
                        const SizedBox(height: AppSizes.p16),

                        AppText.spaceMono(
                          'SYSTEM_CART_COUNT: // $count ITEMS REGISTERED',
                          fontSize: 14,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: AppSizes.p48),

                        cartItemsAsync.when(
                          data: (items) {
                            if (items.isEmpty) {
                              return _buildEmptyCartView(context, textColor);
                            }
                            return isDesktop
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: _buildItemsList(
                                          context,
                                          items,
                                          textColor,
                                        ),
                                      ),
                                      const SizedBox(width: 48),
                                      Expanded(
                                        flex: 2,
                                        child: _buildSummaryPanel(
                                          context,
                                          subtotal,
                                          discountAmount,
                                          shipping,
                                          total,
                                          textColor,
                                          surfaceColor,
                                          cartViewState,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      _buildItemsList(
                                        context,
                                        items,
                                        textColor,
                                      ),
                                      const SizedBox(height: 48),
                                      _buildSummaryPanel(
                                        context,
                                        subtotal,
                                        discountAmount,
                                        shipping,
                                        total,
                                        textColor,
                                        surfaceColor,
                                        cartViewState,
                                      ),
                                    ],
                                  );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(64.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, stack) => Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Error loading cart: $err',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const FooterSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartView(BuildContext context, Color textColor) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.02),
        border: Border.all(color: textColor, width: 3.0),
        image: DecorationImage(
          image: const CachedNetworkImageProvider(
            'https://images.unsplash.com/photo-1557682250-33bd709cbe85?q=80&w=1200&auto=format&fit=crop',
          ), // Subtle texture
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
            BlendMode.srcOver,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: textColor, width: 2.0),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Icon(
              Icons.shopping_cart_checkout,
              size: 64,
              color: textColor,
            ),
          ),
          const SizedBox(height: 32),
          AppText.bebas(
            'BAG EMPTY // PROTOCOL TERMINATED',
            fontSize: isDesktop ? 36 : 24,
            color: textColor,
            textAlign: TextAlign.center,
            letterSpacing: 2.0,
          ),
          const SizedBox(height: 16),
          AppText.spaceMono(
            'NO ITEMS DETECTED IN YOUR CONTAINER STORAGE.\nCOMMENCE BROWSING PROCEDURES.',
            fontSize: isDesktop ? 14 : 11,
            color: textColor.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
            height: 1.5,
          ),
          const SizedBox(height: 48),
          BrutalistHoverWidget(
            shadowColor: AppTheme.neonAccent,
            offset: const Offset(6, 6),
            child: ElevatedButton(
              onPressed: () => context.go(AppPaths.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: textColor,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 24,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: AppText.bebas(
                'BROWSE STREET CAPSULES ↗',
                fontSize: isDesktop ? 20 : 16,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(
    BuildContext context,
    List<CartItem> cartItems,
    Color textColor,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        final product = item.product;
        final imageUrl = product['image'] ?? '';
        final isAsset = imageUrl.startsWith('assets/');

        return Container(
          margin: const EdgeInsets.only(bottom: 24.0),
          decoration: BoxDecoration(
            border: Border.all(color: textColor, width: 3.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Column
              Container(
                width: isDesktop ? 140 : 100,
                height: isDesktop ? 160 : 130,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: textColor, width: 3.0),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child:
                          (item.frontDesignPreview != null &&
                              item.frontDesignPreview!.startsWith('http'))
                          ? AppImage(
                              imageUrl: item.frontDesignPreview!,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              memCacheWidth: 400,
                            )
                          : isAsset
                          ? Image.asset(
                              imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            )
                          : AppImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                              memCacheWidth: 400,
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

              // Product Info Column
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 16.0 : 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AppText.spaceMono(
                              product['name'] ?? '',
                              fontSize: isDesktop ? 14 : 12,
                              fontWeight: FontWeight.bold,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: textColor),
                            onPressed: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .removeItem(item.id);
                              AppSnackBar.show(
                                context,
                                'ITEM REMOVED FROM BAG',
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Size Badge & Config
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            color: textColor.withValues(alpha: 0.1),
                            child: AppText.spaceMono(
                              'SIZE: ${item.size}',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (product['tag'] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              color: textColor,
                              child: AppText.spaceMono(
                                product['tag']!,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (item.customText != null) ...[
                        AppText.spaceMono(
                          '/// PRINT DESIGN CONFIG:\n${item.customText}',
                          fontSize: isDesktop ? 10 : 8,
                          color: Colors.redAccent,
                          height: 1.4,
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Price & Quantity control
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        runSpacing: 8.0,
                        children: [
                          AppText.spaceMono(
                            product['price'] ?? '',
                            fontSize: isDesktop ? 16 : 14,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(width: 8),

                          // Quantity buttons
                          Row(
                            children: [
                              InkWell(
                                onTap: () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(item.id, item.quantity - 1),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: textColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: textColor,
                                      width: 2.0,
                                    ),
                                    bottom: BorderSide(
                                      color: textColor,
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                child: AppText.spaceMono(
                                  item.quantity.toString(),
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              InkWell(
                                onTap: () => ref
                                    .read(cartProvider.notifier)
                                    .updateQuantity(item.id, item.quantity + 1),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: textColor,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: const Icon(Icons.add, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryPanel(
    BuildContext context,
    double subtotal,
    double discount,
    double shipping,
    double total,
    Color textColor,
    Color surfaceColor,
    CartViewState cartViewState,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return Container(
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: 0.03),
        border: Border.all(color: textColor, width: 3.0),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.spaceMono(
            "/// ORDER SYSTEM PROTOCOL",
            fontSize: isDesktop ? 12 : 10,
            fontWeight: FontWeight.bold,
            color: textColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          AppText.bebas(
            "SUMMARY DETAILS",
            fontSize: isDesktop ? 28 : 22,
            color: textColor,
          ),
          const SizedBox(height: 24),

          // Subtotal rows
          _buildSummaryRow(
            'BAG SUBTOTAL',
            '₹${subtotal.toStringAsFixed(0)}',
            textColor,
          ),
          const SizedBox(height: 12),
          if (cartViewState.isPromoApplied) ...[
            _buildSummaryRow(
              'PROMO DISCOUNT (${(cartViewState.discountPercentage * 100).toStringAsFixed(0)}%)',
              '-₹${discount.toStringAsFixed(0)}',
              Colors.redAccent,
            ),
            const SizedBox(height: 12),
          ],
          _buildSummaryRow(
            'SHIPPING ESTIMATE',
            shipping == 0 ? 'FREE' : '₹${shipping.toStringAsFixed(0)}',
            textColor,
          ),

          if (shipping > 0) ...[
            const SizedBox(height: 8),
            AppText.spaceMono(
              'Add ₹${(5000 - subtotal).toStringAsFixed(0)} more for FREE shipping!',
              fontSize: 10,
              color: Colors.redAccent,
            ),
          ],

          const SizedBox(height: 16),
          Divider(color: textColor, thickness: 2.0),
          const SizedBox(height: 16),

          _buildSummaryRow(
            'GRAND TOTAL',
            '₹${total.toStringAsFixed(0)}',
            textColor,
            isBold: true,
            fontSize: isDesktop ? 16 : 14,
          ),

          const SizedBox(height: 32),

          // Promo code input
          AppText.spaceMono(
            "PROMO CODE:",
            fontSize: isDesktop ? 11 : 9,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          const SizedBox(height: 8),

          cartViewState.isPromoApplied
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.spaceMono(
                        'ACTIVE: ${cartViewState.appliedPromoCode}',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.redAccent,
                          size: 18,
                        ),
                        onPressed: _removePromoCode,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: AppField(
                        hintText: "E.g. TOURER15, ANTIGRAVITY",
                        controller: _promoController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    BrutalistHoverWidget(
                      shadowColor: textColor.withValues(alpha: 0.1),
                      offset: const Offset(3, 3),
                      child: InkWell(
                        onTap: _applyPromoCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: textColor,
                            border: Border.all(color: textColor, width: 2.0),
                          ),
                          alignment: Alignment.center,
                          child: AppText.bebas(
                            'APPLY',
                            fontSize: isDesktop ? 14 : 12,
                            color: surfaceColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 32),

          // Checkout button
          BrutalistHoverWidget(
            shadowColor: textColor.withValues(alpha: 0.2),
            offset: const Offset(6, 6),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _handleCheckout(cartViewState.discountPercentage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonAccent,
                  foregroundColor: AppTheme.pureBlack,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                    side: BorderSide(color: AppTheme.pureBlack, width: 2),
                  ),
                ),
                child: AppText.bebas(
                  'PROCEED TO SECURE CHECKOUT ↗',
                  fontSize: isDesktop ? 22 : 16,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String val,
    Color color, {
    bool isBold = false,
    double fontSize = 12,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText.spaceMono(
          label,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
        AppText.spaceMono(
          val,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ],
    );
  }
}
