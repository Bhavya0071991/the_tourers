import 'package:equatable/equatable.dart';

class ProductDetailsState extends Equatable {
  final String selectedSize;
  final String selectedColor;
  final int currentMediaIndex;
  final String customText;

  final List<String> availableSizes;
  final Map<String, List<String>> availableColors;
  final String defaultPlace;
  final String quoteTemplate;

  const ProductDetailsState({
    this.selectedSize = 'L',
    this.selectedColor = 'Black',
    this.currentMediaIndex = 0,
    this.customText = '',
    this.availableSizes = const ['S', 'M', 'L', 'XL', 'XXL'],
    this.availableColors = const {},
    this.defaultPlace = '',
    this.quoteTemplate = '',
  });

  ProductDetailsState copyWith({
    String? selectedSize,
    String? selectedColor,
    int? currentMediaIndex,
    String? customText,
    List<String>? availableSizes,
    Map<String, List<String>>? availableColors,
    String? defaultPlace,
    String? quoteTemplate,
  }) {
    return ProductDetailsState(
      selectedSize: selectedSize ?? this.selectedSize,
      selectedColor: selectedColor ?? this.selectedColor,
      currentMediaIndex: currentMediaIndex ?? this.currentMediaIndex,
      customText: customText ?? this.customText,
      availableSizes: availableSizes ?? this.availableSizes,
      availableColors: availableColors ?? this.availableColors,
      defaultPlace: defaultPlace ?? this.defaultPlace,
      quoteTemplate: quoteTemplate ?? this.quoteTemplate,
    );
  }

  @override
  List<Object?> get props => [
        selectedSize,
        selectedColor,
        currentMediaIndex,
        customText,
        availableSizes,
        availableColors,
        defaultPlace,
        quoteTemplate,
      ];
}
