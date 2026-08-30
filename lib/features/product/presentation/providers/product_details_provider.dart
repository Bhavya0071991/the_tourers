import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';
import '../../../cart/providers/cart_provider.dart';
import 'product_details_state.dart';

class ProductDetailsNotifier extends Notifier<ProductDetailsState> {
  @override
  ProductDetailsState build() {
    return const ProductDetailsState();
  }

  void initializeProduct(Product product) {
    final tag = product.tag;
    final id = product.id;
    String defaultPlace = '';
    String quoteTemplate = '';

    if (tag == 'QUOTE') {
      if (id == 'm1') {
        defaultPlace = 'TOKYO';
        quoteTemplate = "LET'S TRAVEL TO %s";
      } else if (id == 'm5') {
        defaultPlace = 'AMSTERDAM';
        quoteTemplate = 'NO COMPROMISE IN %s';
      } else if (id == 'w1') {
        defaultPlace = 'PARIS';
        quoteTemplate = 'DREAMING OF %s';
      } else if (id == 'w5') {
        defaultPlace = 'BERLIN';
        quoteTemplate = 'THINK DIFFERENTLY IN %s';
      } else {
        defaultPlace = 'LONDON';
        quoteTemplate = "LET'S TRAVEL TO %s";
      }
    }

    Map<String, List<String>> colors = Map.from(product.colorImages);
    
    // Fallback for older products that don't have color_images yet
    if (colors.isEmpty) {
      if (tag == 'QUOTE') {
        colors = {
          'Black': ['assets/images/plain_black_tee.png'],
          'White': ['assets/images/plain_white_tee.png'],
          'Grey': ['assets/images/plain_grey_tee.png'],
        };
      } else if (product.images.isNotEmpty) {
        colors = {'Black': product.images};
      } else if (product.image != null) {
        colors = {'Black': [product.image!]};
      }
    }

    String selectedColor = colors.isNotEmpty ? colors.keys.first : 'Black';

    state = const ProductDetailsState().copyWith(
      defaultPlace: defaultPlace,
      quoteTemplate: quoteTemplate,
      customText: defaultPlace,
      currentMediaIndex: 0,
      availableColors: colors,
      selectedColor: selectedColor,
    );
  }

  void updateSize(String size) {
    state = state.copyWith(selectedSize: size);
  }

  void updateColor(String color) {
    state = state.copyWith(selectedColor: color);
  }

  void updateMediaIndex(int index) {
    state = state.copyWith(currentMediaIndex: index);
  }

  void updateCustomText(String text) {
    state = state.copyWith(customText: text);
  }

  /// Handles the logic to add the item to the cart
  Future<void> addToCart(
    Product product,
    String customQuote,
    String resolvedMockupUrl,
  ) async {
    final productToAdd = product.toMap();
    String? displayImage;
    String? frontPrintUrl;

    if (state.availableColors.containsKey(state.selectedColor) && 
        state.availableColors[state.selectedColor]!.isNotEmpty) {
      displayImage = state.availableColors[state.selectedColor]!.first;
      productToAdd['image'] = displayImage;
    }

    if (product.colorDesignImages.containsKey(state.selectedColor)) {
      frontPrintUrl = product.colorDesignImages[state.selectedColor];
    } else if (product.colorDesignImages.containsKey('Black')) {
      frontPrintUrl = product.colorDesignImages['Black'];
    }

    if (resolvedMockupUrl.isNotEmpty) {
      productToAdd['mockup'] = resolvedMockupUrl;
      displayImage = resolvedMockupUrl;
    }

    await ref
        .read(cartProvider.notifier)
        .addItem(
          productToAdd,
          '${state.selectedSize} / ${state.selectedColor}',
          customText: customQuote.isNotEmpty ? customQuote : null,
          frontDesignPreview: displayImage,
          frontPrintUrl: frontPrintUrl,
        );
  }
}

final productDetailsProvider =
    NotifierProvider<ProductDetailsNotifier, ProductDetailsState>(
      ProductDetailsNotifier.new,
    );
