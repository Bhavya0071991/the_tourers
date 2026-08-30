import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import '../../../../core/extensions/build_context_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../review/providers/review_provider.dart';
import '../../../review/presentation/widgets/review_card.dart';
import '../../../home/presentation/widgets/benefits_section.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../wishlist/providers/wishlist_provider.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_field.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../home/presentation/widgets/promo_banner.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/mockup_image_widget.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/product.dart';
import '../providers/product_details_provider.dart';
import '../providers/product_details_state.dart';

import '../widgets/image_zoom_on_hover.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, String> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  late final TextEditingController _customTextController;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    final product = Product.fromMap(widget.product);
    _customTextController = TextEditingController();

    // Defer state modification until after the initial build phase
    Future.microtask(() {
      ref.read(productDetailsProvider.notifier).initializeProduct(product);
      final initialText = ref.read(productDetailsProvider).defaultPlace;
      _customTextController.text = initialText;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _customTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    final product = Product.fromMap(widget.product);

    return Scaffold(
      bottomNavigationBar: isDesktop
          ? null
          : Consumer(
              builder: (context, ref, _) {
                final state = ref.watch(productDetailsProvider);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: context.colorScheme.onSurface,
                        width: 2,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: _buildAddToBagButton(context, product, state),
                  ),
                );
              },
            ),
      body: Column(
        children: [
          const PromoBanner(),
          const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final state = ref.watch(productDetailsProvider);
                      return isDesktop
                          ? _buildDesktopLayout(context, product, state)
                          : _buildMobileLayout(context, product, state);
                    },
                  ),

                  // Added Benefits Section at the bottom of the details
                  const BenefitsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    Product product,
    ProductDetailsState state,
  ) {
    return WebConstrainedBox(
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Massive Image with print overlay
            Expanded(
              flex: 5,
              child: _buildProductImageWithOverlay(
                context,
                product,
                state,
                isDesktop: true,
              ),
            ),
            // Right Side: Brutalist Product Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 64.0,
                  vertical: 48.0,
                ),
                child: _buildProductInfo(
                  context,
                  product,
                  state,
                  isDesktop: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    Product product,
    ProductDetailsState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top: Image with print overlay
        _buildProductImageWithOverlay(
          context,
          product,
          state,
          isDesktop: false,
        ),
        // Bottom: Product Info
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildProductInfo(context, product, state, isDesktop: false),
        ),
      ],
    );
  }

  Widget _buildProductImageWithOverlay(
    BuildContext context,
    Product product,
    ProductDetailsState state, {
    double? height,
    required bool isDesktop,
  }) {
    final isQuoteProduct = product.tag == 'QUOTE';
    // Use dynamic images from backend

    // Use dynamic images from backend
    final List<Map<String, String>> mediaList = [];
    final List<String> currentImages =
        state.availableColors.isNotEmpty &&
            state.availableColors.containsKey(state.selectedColor)
        ? state.availableColors[state.selectedColor]!
        : product.images;

    final firstImageUrl = currentImages.isNotEmpty
        ? currentImages.first
        : (product.image ?? '');

    if (firstImageUrl.isNotEmpty) {
      mediaList.add({'type': 'image', 'url': firstImageUrl});
    }
    for (final imgUrl in currentImages) {
      // Avoid duplicating the main image if it's already in the list
      if (imgUrl != firstImageUrl) {
        mediaList.add({'type': 'image', 'url': imgUrl});
      }
    }

    // Fallback just in case no image is provided at all
    if (mediaList.isEmpty) {
      mediaList.add({
        'type': 'image',
        'url': 'https://placehold.co/800x1000.png?text=No+Image',
      });
    }

    final containerHeight =
        height ??
        (isDesktop
            ? MediaQuery.of(context).size.height - kToolbarHeight
            : 500.0);

    // 1. The base content (images/videos)
    Widget contentLayer = PageView.builder(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      onPageChanged: (index) {
        ref.read(productDetailsProvider.notifier).updateMediaIndex(index);
      },
      itemBuilder: (context, index) {
        final media = mediaList[index];

        if (media['type'] == 'video') {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline,
                  size: 80,
                  color: Colors.black54,
                ),
                SizedBox(height: 16),
                Text(
                  'Video Placeholder',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        String? mockupAsset;
        if (index == 0 && product.mockup != null) {
          // For quote products, we used to use local assets. Now we can use the first image of the variant.
          if (state.availableColors.containsKey(state.selectedColor) &&
              state.availableColors[state.selectedColor]!.isNotEmpty) {
            mockupAsset = state.availableColors[state.selectedColor]!.first;
          } else {
            mockupAsset = media['url'];
          }
        }
        return MockupImageWidget(
          image: media['url']!,
          mockup: mockupAsset,
          fit: BoxFit.cover,
        );
      },
    );

    // 2. The quote text overlay (if applicable)
    if (isQuoteProduct) {
      final customValue = _customTextController.text.trim().isEmpty
          ? state.defaultPlace
          : _customTextController.text.toUpperCase();
      final customQuote = state.quoteTemplate.replaceAll('%s', customValue);

      final double topOffset = isDesktop ? 220 : 160;
      final double textFontSize = isDesktop ? 28 : 20;

      final productId = product.id;
      final textColor =
          (productId == 'm1' || productId == 'w1' || productId == 'w6')
          ? Colors.black87
          : Colors.white;

      contentLayer = Stack(
        children: [
          contentLayer,
          if (state.currentMediaIndex ==
              0) // Only show text over the first image
            Positioned(
              top: topOffset,
              left: 40,
              right: 40,
              child: IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppText.bebas(
                        customQuote,
                        fontSize: textFontSize,
                        color: textColor,
                        textAlign: TextAlign.center,
                        letterSpacing: 1.5,
                        height: 1.0,
                      ),
                      const SizedBox(height: 4),
                      AppText.spaceMono(
                        "ANTIGRAVITY",
                        fontSize: textFontSize * 0.35,
                        color: textColor.withValues(alpha: 0.6),
                        letterSpacing: 2.0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // 3. Apply Zoom on Hover (Desktop Only)
    if (isDesktop) {
      // Must import the widget at the top of the file if not already imported
      contentLayer = ImageZoomOnHover(child: contentLayer);
    }

    // 4. Combine with navigation controls
    return Container(
      height: containerHeight,
      width: double.infinity,
      color: context.colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          Positioned.fill(child: contentLayer),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                mediaList.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: state.currentMediaIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.currentMediaIndex == index
                        ? AppTheme.neonAccent
                        : context.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          if (state.currentMediaIndex > 0)
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
          if (state.currentMediaIndex < mediaList.length - 1)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(
    BuildContext context,
    Product product,
    ProductDetailsState state, {
    required bool isDesktop,
  }) {
    final isQuoteProduct = product.tag == 'QUOTE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and Wishlist Button
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AppText.bebas(
                product.name.toUpperCase(),
                fontSize: isDesktop ? 72 : 32,
                height: 0.9,
                color: context.colorScheme.onSurface,
              ),
            ),
            Consumer(
              builder: (context, ref, child) {
                final wishlist = ref.watch(wishlistProvider).value ?? [];
                final isWishlisted = wishlist.any(
                  (item) => item.productId == product.id,
                );

                return IconButton(
                  iconSize: 40,
                  icon: Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted
                        ? Colors.redAccent
                        : context.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    final authState = ref.read(authProvider).value;
                    if (authState == null ||
                        authState.status != AuthStatus.authenticated ||
                        authState.id == null) {
                      AppSnackBar.show(
                        context,
                        'Please login first to make a wishlist',
                        isError: true,
                      );
                      return;
                    }
                    ref
                        .read(wishlistProvider.notifier)
                        .toggleWishlist(product.id);
                  },
                );
              },
            ),
          ],
        ),
        SizedBox(height: isDesktop ? AppSizes.p24 : AppSizes.p16),

        // Price Block
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: context.colorScheme.onSurface, width: 4),
              bottom: BorderSide(
                color: context.colorScheme.onSurface,
                width: 4,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.spaceMono(
                product.price,
                fontSize: isDesktop ? 32 : 20,
                fontWeight: FontWeight.w700,
                color: context.colorScheme.onSurface,
              ),
              if (product.originalPrice != null)
                AppText.spaceMono(
                  product.originalPrice!,
                  fontSize: isDesktop ? 24 : 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.4),
                  decoration: TextDecoration.lineThrough,
                ),
            ],
          ),
        ),

        // Product Description
        if (product.description != null && product.description!.isNotEmpty) ...[
          SizedBox(height: isDesktop ? AppSizes.p32 : AppSizes.p24),
          AppText.spaceMono(
            product.description!,
            fontSize: isDesktop ? 16 : 14,
            height: 1.6,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ],
        SizedBox(height: isDesktop ? AppSizes.p48 : AppSizes.p32),

        // Brutalist Badges
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: context.colorScheme.onSurface),
          child: AppText.spaceMono(
            "/// PREMIUM QUALITY /// 100% COTTON /// HEAVYWEIGHT DTG PRINT ///",
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.surface,
            textAlign: TextAlign.center,
            letterSpacing: 2.0,
          ),
        ),
        SizedBox(height: isDesktop ? AppSizes.p48 : AppSizes.p32),

        // Color Selector
        AppText.spaceMono(
          'SELECT COLOR',
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: context.colorScheme.onSurface,
        ),
        SizedBox(height: isDesktop ? AppSizes.p16 : AppSizes.p12),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: state.availableColors.keys.map((colorName) {
            final isSelected = colorName == state.selectedColor;
            return BrutalistHoverWidget(
              shadowColor: context.colorScheme.onSurface,
              offset: const Offset(4, 4),
              child: InkWell(
                onTap: () {
                  ref
                      .read(productDetailsProvider.notifier)
                      .updateColor(colorName);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 24 : 16,
                    vertical: isDesktop ? 16 : 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.onSurface
                        : context.colorScheme.surface,
                    border: Border.all(
                      color: context.colorScheme.onSurface,
                      width: 2,
                    ),
                  ),
                  child: AppText.spaceMono(
                    colorName.toUpperCase(),
                    fontSize: isDesktop ? 16 : 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? context.colorScheme.surface
                        : context.colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: isDesktop ? AppSizes.p48 : AppSizes.p32),

        // Size Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.spaceMono(
              AppStrings.productSelectSize,
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: context.colorScheme.onSurface,
            ),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const _SizeGuideDialog(),
                );
              },
              icon: Icon(
                Icons.straighten,
                size: isDesktop ? 16 : 14,
                color: AppTheme.neonAccent,
              ),
              label: AppText.spaceMono(
                'SIZE GUIDE',
                fontSize: isDesktop ? 12 : 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.neonAccent,
                decoration: TextDecoration.underline,
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        SizedBox(height: isDesktop ? AppSizes.p16 : AppSizes.p12),
        Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: state.availableSizes.map((size) {
            final isSelected = size == state.selectedSize;
            return BrutalistHoverWidget(
              shadowColor: context.colorScheme.onSurface,
              offset: const Offset(4, 4),
              child: InkWell(
                onTap: () {
                  ref.read(productDetailsProvider.notifier).updateSize(size);
                },
                child: Container(
                  width: isDesktop ? 64 : 48,
                  height: isDesktop ? 64 : 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.colorScheme.onSurface
                        : context.colorScheme.surface,
                    border: Border.all(
                      color: context.colorScheme.onSurface,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: AppText.spaceMono(
                      size,
                      fontSize: isDesktop ? 18 : 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? context.colorScheme.surface
                          : context.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: isDesktop ? AppSizes.p48 : AppSizes.p32),

        if (isQuoteProduct) ...[
          _buildQuoteCustomizer(context, product),
          SizedBox(height: isDesktop ? AppSizes.p48 : AppSizes.p32),
        ],

        // Brutalist Add To Bag Button (Desktop only here, Mobile uses sticky bottom bar)
        if (isDesktop) ...[
          _buildAddToBagButton(context, product, state),
          const SizedBox(height: AppSizes.p48),
        ],

        // Brutalist Accordion / Details
        // Trust Banner
        _buildTrustBanner(context),
        const SizedBox(height: 32),

        // Accordions
        _buildExpandableSection(
          context,
          title: 'Product Description',
          subtitle: 'Manufacture, Care and Fit',
          leadingIcon: Icons.description_outlined,
          initiallyExpanded: true,
          child: _buildProductDescriptionContent(context),
        ),
        _buildExpandableSection(
          context,
          title: 'Shipping Info',
          subtitle: 'We Offer free shipping across India',
          leadingIcon: Icons.local_shipping_outlined,
          child: _buildShippingInfoContent(context),
        ),
        _buildExpandableSection(
          context,
          title: '7 Days Returns & Exchange',
          subtitle: 'Know about return & exchange policy',
          leadingIcon: Icons.published_with_changes_outlined,
          child: _buildReturnsPolicyContent(context),
        ),
        const SizedBox(height: 32),
        _buildCustomerReviews(context, product.id),
      ],
    );
  }

  bool _isAddingToCart = false;

  /// Performs the actual add-to-cart logic (assumes user is authenticated).
  Future<void> _performAddToCart(
    Product product,
    ProductDetailsState state,
  ) async {
    setState(() => _isAddingToCart = true);
    try {
      final isQuoteProduct = product.tag == 'QUOTE';
      String message;
      String? customQuote;

      if (isQuoteProduct) {
        final customValue = _customTextController.text.trim().isEmpty
            ? state.defaultPlace
            : _customTextController.text.toUpperCase();
        customQuote = state.quoteTemplate.replaceAll('%s', customValue);
        message =
            'ADDED SIZE ${state.selectedSize} [${state.selectedColor}] [$customQuote TEE] TO BAG!';
      } else {
        message = AppStrings.productAddedBag.replaceAll(
          '%s',
          '${state.selectedSize} [${state.selectedColor}]',
        );
      }

      final resolvedMockupUrl = product.mockup != null
          ? (state.availableColors.containsKey(state.selectedColor) &&
                    state.availableColors[state.selectedColor]!.isNotEmpty
                ? state.availableColors[state.selectedColor]!.first
                : '')
          : '';

      await ref
          .read(productDetailsProvider.notifier)
          .addToCart(product, customQuote ?? '', resolvedMockupUrl);

      if (mounted) {
        // Trigger our unified Brutalist snackbar!
        AppSnackBar.show(context, message);
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, 'Failed to add item: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isAddingToCart = false);
      }
    }
  }

  Widget _buildAddToBagButton(
    BuildContext context,
    Product product,
    ProductDetailsState state,
  ) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    return BrutalistHoverWidget(
      shadowColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.2),
      offset: const Offset(8, 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isAddingToCart
              ? null
              : () async {
                  // Check if user is logged in before adding to cart
                  final authState = ref.read(authProvider);
                  if (authState.value?.status != AuthStatus.authenticated) {
                    // Navigate to auth page and wait for user to return
                    await context.push(AppPaths.auth);

                    // After returning, check if user is now authenticated
                    if (!mounted) return;
                    final updatedAuthState = ref.read(authProvider);
                    if (updatedAuthState.value?.status ==
                        AuthStatus.authenticated) {
                      // User logged in successfully — add item to cart automatically
                      await _performAddToCart(product, state);
                    }
                    // If still unauthenticated, do nothing (user cancelled login)
                    return;
                  }

                  // User is already authenticated — add to cart directly
                  await _performAddToCart(product, state);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.neonAccent,
            foregroundColor: AppTheme.pureBlack,
            padding: const EdgeInsets.symmetric(vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
              side: const BorderSide(color: AppTheme.pureBlack, width: 2),
            ),
          ),
          child: _isAddingToCart
              ? const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: AppTheme.pureBlack,
                    strokeWidth: 3,
                  ),
                )
              : AppText.bebas(
                  AppStrings.productAddBag,
                  fontSize: isDesktop ? 32 : 22,
                  letterSpacing: 2.0,
                ),
        ),
      ),
    );
  }

  Widget _buildQuoteCustomizer(BuildContext context, Product product) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final isQuoteProduct = product.tag == 'QUOTE';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.spaceMono(
          isQuoteProduct ? 'QUOTE CONFIGURATION' : 'SELECT SIZE',
          fontSize: isDesktop ? 16 : 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
          color: context.colorScheme.onSurface,
        ),
        const SizedBox(height: AppSizes.p16),
        AppText.spaceMono(
          "Type your location or country below. Custom typography will be dynamically formatted and printed on the live streetwear DTG blueprint.",
          fontSize: isDesktop ? 13 : 11,
          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
          height: 1.5,
        ),
        const SizedBox(height: AppSizes.p24),
        AppField(
          hintText: "E.g., SHIBUYA, BALI, ICELAND",
          controller: _customTextController,
          onChanged: (val) {
            // Keep local state in sync (or rely on controller text directly)
            setState(() {});
          },
        ),
        const SizedBox(height: AppSizes.p32),
        _buildPrintBlueprint(context),
      ],
    );
  }

  Widget _buildPrintBlueprint(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;
    final state = ref.watch(productDetailsProvider);
    final customValue = _customTextController.text.trim().isEmpty
        ? state.defaultPlace
        : _customTextController.text.toUpperCase();
    final customQuote = state.quoteTemplate.replaceAll('%s', customValue);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.colorScheme.onSurface,
        border: Border.all(color: context.colorScheme.onSurface, width: 4),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.spaceMono(
                "/// LIVE DTG PRINT BLUEPRINT",
                fontSize: isDesktop ? 12 : 10,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.surface,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: Colors.redAccent,
                child: AppText.spaceMono(
                  "CUSTOMIZED",
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            color: context.colorScheme.surface.withValues(alpha: 0.3),
            thickness: 1.5,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.spaceMono(
                        "01_FRONT_CHEST",
                        fontSize: 9,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.5),
                      ),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: context.colorScheme.surface,
                              width: 1.5,
                            ),
                          ),
                          child: AppText.bebas(
                            "ANTIGRAVITY",
                            fontSize: 16,
                            color: context.colorScheme.surface,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      AppText.spaceMono(
                        "[MINIMAL_LOGO]",
                        fontSize: 8,
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 6,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.spaceMono(
                            "02_BACK_LARGE",
                            fontSize: 9,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.5),
                          ),
                          AppText.spaceMono(
                            "SCALE: 1:1.5",
                            fontSize: 8,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText.spaceMono(
                              "SYS_LOC: // ${customValue.replaceAll(' ', '_')}",
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                              letterSpacing: 1.0,
                            ),
                            const SizedBox(height: 6),
                            AppText.bebas(
                              customQuote,
                              fontSize: 22,
                              color: context.colorScheme.surface,
                              textAlign: TextAlign.center,
                              letterSpacing: 1.0,
                              height: 1.0,
                            ),
                            const SizedBox(height: 6),
                            AppText.spaceMono(
                              "ANTIGRAVITY LABS © 2026",
                              fontSize: 7,
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.5),
                              letterSpacing: 1.5,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText.spaceMono(
                            "DTG_WHITE_INK",
                            fontSize: 8,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.4),
                          ),
                          AppText.spaceMono(
                            "O_SIZED_FIT",
                            fontSize: 8,
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: context.colorScheme.surface.withValues(alpha: 0.2),
            thickness: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText.spaceMono(
                "TECH: HIGH-DENSITY DIRECT TO GARMENT",
                fontSize: 8,
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.6),
              ),
              AppText.spaceMono(
                "STATUS: ACTIVE_CUSTOM_VAL",
                fontSize: 8,
                color: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.onSurface, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface,
            offset: const Offset(4, 4),
          ),
        ],
        borderRadius: BorderRadius.zero,
        color: Theme.of(context).brightness == Brightness.dark
            ? context.colorScheme.surfaceContainerHighest
            : context.colorScheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrustItem(
            context,
            Icons.payments_outlined,
            'CASH ON\nDELIVERY',
          ),
          _buildTrustItem(
            context,
            Icons.local_shipping_outlined,
            'FREE SHIPPING\nON ALL ORDERS',
          ),
          _buildTrustItem(
            context,
            Icons.swap_horizontal_circle_outlined,
            'EASY\nRETURNS',
          ),
        ],
      ),
    );
  }

  Widget _buildTrustItem(BuildContext context, IconData icon, String text) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 32, color: context.colorScheme.onSurface),
          const SizedBox(height: 12),
          AppText.spaceMono(
            text,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
            color: context.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    required Widget child,
    bool initiallyExpanded = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.onSurface, width: 2),
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface,
            offset: const Offset(4, 4),
          ),
        ],
        color: context.colorScheme.surface,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          iconColor: context.colorScheme.onSurface,
          collapsedIconColor: context.colorScheme.onSurface,
          leading: leadingIcon != null
              ? Icon(leadingIcon, color: context.colorScheme.onSurface)
              : null,
          title: AppText.spaceMono(
            title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
          ),
          subtitle: subtitle != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: AppText.spaceMono(
                    subtitle,
                    fontSize: 12,
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                )
              : null,
          childrenPadding: const EdgeInsets.only(bottom: 24),
          children: [child],
        ),
      ),
    );
  }

  Widget _buildProductDescriptionContent(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(context, 'Made of', 'Textured'),
        _buildInfoRow(context, 'Neck Type', 'Round Neck'),
        _buildInfoRow(context, 'Fit Type', 'Oversized Fit'),
        _buildInfoRow(context, 'Color', 'Green'),
        _buildInfoRow(context, 'Pattern', 'Textured'),
        _buildInfoRow(context, 'Sleeve Type', 'Half Sleeve'),
        _buildInfoRow(context, 'Care Instructions', 'Machine washable'),
        _buildInfoRow(context, 'Available Sizes', 'S, M, L, XL, XXL'),

        _buildInfoRow(context, 'GSM', '220'),
        _buildInfoRow(context, 'Country of origin', 'India'),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: AppText.spaceMono(
              label,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: context.colorScheme.onSurface,
            ),
          ),
          Expanded(
            flex: 6,
            child: AppText.spaceMono(
              value,
              fontSize: 13,
              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingInfoContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 48.0,
      ), // pad more to align with text
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextContent(
            context,
            'Shipping Info',
            'We offer free shipping across India',
          ),
          const SizedBox(height: 16),
          _buildTextContent(
            context,
            '1-2 Days Dispatch',
            'We dispatch orders within 1-2 days.',
          ),
          const SizedBox(height: 16),
          _buildTextContent(
            context,
            '2-5 Days Delivery',
            'We usually take 2-5 working days depending on your location.\nMetros 2-3 days\nRest of India 3-5 days',
          ),
          const SizedBox(height: 16),
          _buildTextContent(context, 'Customer Support', '99999 22222'),
        ],
      ),
    );
  }

  Widget _buildReturnsPolicyContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0), // align with title
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.spaceMono(
            'Items purchased from The Tourers are eligible for return/exchange, if returned within 7 days of delivery.',
            fontSize: 13,
            color: context.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
          const SizedBox(height: 16),
          _buildTextContent(
            context,
            'Free Exchanges',
            'We accept exchanges free of cost. This means you wont be charged extra to exchange the product(s). It\'s on us! We want your experience to be hassle-free.',
          ),
          const SizedBox(height: 16),
          _buildTextContent(
            context,
            'Easy Returns',
            'For Prepaid Orders - The full amount is refunded into your initial payment mode (bank account, credit card, etc.)\n\nFor Cash on Delivery Orders - The order amount will be refunded to your bank account. You can provide your bank/upi detail. COD charges are non-refundable.',
          ),
          const SizedBox(height: 16),
          _buildTextContent(
            context,
            'Exchange For Something Else?',
            'In case of an exchange, you are also allowed to choose a different product. If the value of the replacement product exceeds that of the previously purchased product, you can pay just the difference else if it\'s less, the same can be refunded to you as gift card.',
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context, String title, String body) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.spaceMono(
          title,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: context.colorScheme.onSurface,
        ),
        const SizedBox(height: 8),
        AppText.spaceMono(
          body,
          fontSize: 13,
          color: context.colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.5,
        ),
      ],
    );
  }

  Widget _buildCustomerReviews(BuildContext context, String productId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.bebas(
          'CUSTOMER REVIEWS',
          fontSize: 24,
          letterSpacing: 2.0,
          color: context.colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Consumer(
          builder: (context, ref, child) {
            final reviewsAsync = ref.watch(productReviewsProvider(productId));

            return reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    child: Center(
                      child: AppText.spaceMono(
                        'Be the first to review this product.\nYou can leave a review from the "My Orders" page after purchasing.',
                        fontSize: 12,
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                        textAlign: TextAlign.center,
                        height: 1.5,
                      ),
                    ),
                  );
                }

                final double avgRating =
                    reviews.fold(0.0, (sum, item) => sum + item.rating) /
                    reviews.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 8),
                        AppText.bebas(
                          '${avgRating.toStringAsFixed(1)} / 5',
                          fontSize: 24,
                          color: context.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.1,
                            ),
                          ),
                          child: AppText.spaceMono(
                            '${reviews.length} REVIEW${reviews.length > 1 ? 'S' : ''}',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ...reviews.map((review) => ReviewCard(review: review)),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppText.spaceMono(
                'Error loading reviews',
                fontSize: 12,
                color: Colors.red,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SizeGuideDialog extends StatelessWidget {
  const _SizeGuideDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.spaceMono(
                    'OVERSIZED T-SHIRT',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: context.colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Table
              Table(
                border: TableBorder.all(color: context.colorScheme.outline),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      _buildHeaderCell('Size'),
                      _buildHeaderCell('Chest (In Inches)'),
                      _buildHeaderCell('Length (In Inches)'),
                    ],
                  ),
                  _buildDataRow('S', '42', '28'),
                  _buildDataRow('M', '44', '29'),
                  _buildDataRow('L', '46', '30'),
                  _buildDataRow('XL', '48', '31'),
                  _buildDataRow('XXL', '50', '31.5'),
                ],
              ),
              const SizedBox(height: 24),
              // Image Placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: AppText.spaceMono(
                  'REGULAR FIT v/s OVERSIZED FIT\n(Image Placeholder)',
                  fontSize: 14,
                  textAlign: TextAlign.center,
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AppText.spaceMono(
        text,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
    );
  }

  TableRow _buildDataRow(String size, String chest, String length) {
    return TableRow(
      children: [
        _buildDataCell(size, isBold: true),
        _buildDataCell(chest),
        _buildDataCell(length),
      ],
    );
  }

  Widget _buildDataCell(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: AppText.spaceMono(
        text,
        fontSize: 14,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        textAlign: TextAlign.center,
      ),
    );
  }
}
