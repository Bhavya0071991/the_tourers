import 'package:equatable/equatable.dart';
import '../../../product/domain/entities/product.dart';

class PortraitDesign extends Equatable {
  final String id;
  final String name;
  final String price;
  final String? originalPrice;
  final String description;
  final String imageUrl;
  final String designUrl;
  final String designerName;
  final String designerBio;
  final String designerSignatureUrl;
  final String category; // 'Shimla Heritage', 'Street Art', 'Cyberpunk', etc.

  const PortraitDesign({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.imageUrl,
    required this.designUrl,
    required this.designerName,
    required this.designerBio,
    required this.designerSignatureUrl,
    required this.category,
  });

  /// Converts this portrait design into a standard Product representation
  /// so it can be added to the cart and checkout using existing code.
  Product toProduct({String? selectedSize, String? selectedFrame}) {
    final displayName = selectedFrame != null 
        ? '$name ($selectedFrame Frame)' 
        : name;
    
    return Product(
      id: id,
      name: displayName,
      price: price,
      originalPrice: originalPrice,
      description: description,
      image: imageUrl,
      images: [imageUrl],
      mockup: imageUrl,
      colorDesignImages: {'Black': designUrl},
      gender: 'unisex',
      category: 'portraits',
      tag: category.toUpperCase(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        originalPrice,
        description,
        imageUrl,
        designUrl,
        designerName,
        designerBio,
        designerSignatureUrl,
        category,
      ];
}
