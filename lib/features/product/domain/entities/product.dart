import 'dart:convert';
// ignore_for_file: use_null_aware_elements
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  static Map<String, List<String>> _decodeColorImages(String jsonStr) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, List<String>.from(v)));
    } catch (e) {
      return {};
    }
  }

  static String _encodeColorImages(Map<String, List<String>> map) {
    return jsonEncode(map);
  }

  static Map<String, String> _decodeColorDesignImages(String jsonStr) {
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (e) {
      return {};
    }
  }

  static String _encodeColorDesignImages(Map<String, String> map) {
    return jsonEncode(map);
  }

  final String id;
  final String name;
  final String price;
  final String? originalPrice;
  final String? description;
  final String? image; // Primary image for backwards compatibility
  final List<String> images; // Gallery images
  final Map<String, List<String>> colorImages; // Images per color variant
  final Map<String, String> colorDesignImages; // Transparent PNG per color variant
  final String? mockup;
  final String? tag;
  final String gender; // 'mens', 'womens', 'unisex'
  final String category; // 'design', 'quotes', 'anime', etc.
  final bool isFavorite;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice,
    this.description,
    this.image,
    this.images = const [],
    this.colorImages = const {},
    this.colorDesignImages = const {},
    this.mockup,
    this.tag,
    required this.gender,
    required this.category,
    this.isFavorite = false,
  });

  /// Factory constructor to create a Product from the routing parameters Map
  factory Product.fromMap(Map<String, String> map) {
    // Deserialize images if they exist, otherwise fallback to the primary image
    List<String> parsedImages = [];
    if (map['images'] != null && map['images']!.isNotEmpty) {
      parsedImages = map['images']!.split('||');
    } else if (map['image'] != null) {
      parsedImages = [map['image']!];
    }

    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? 'UNKNOWN PRODUCT',
      price: map['price'] ?? '₹0.00',
      originalPrice: map['originalPrice'],
      description: map['description'],
      image: map['image'],
      images: parsedImages,
      colorImages: map['colorImages'] != null ? _decodeColorImages(map['colorImages']!) : const {},
      colorDesignImages: map['colorDesignImages'] != null ? _decodeColorDesignImages(map['colorDesignImages']!) : const {},
      mockup: map['mockup'],
      tag: map['tag'],
      gender: map['gender'] ?? 'mens',
      category: map['category'] ?? 'design',
      isFavorite: map['isFavorite'] == 'true',
    );
  }

  /// Factory constructor to create a Product from Supabase JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null && json['images'] is List) {
      parsedImages = (json['images'] as List).map((e) => e.toString()).toList();
    } else if (json['image'] != null) {
      parsedImages = [json['image'].toString()];
    }

    Map<String, List<String>> parsedColorImages = {};
    if (json['color_images'] != null && json['color_images'] is Map) {
      final map = json['color_images'] as Map;
      map.forEach((key, value) {
        if (value is List) {
          parsedColorImages[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    }

    Map<String, String> parsedColorDesignImages = {};
    if (json['color_design_images'] != null && json['color_design_images'] is Map) {
      final map = json['color_design_images'] as Map;
      map.forEach((key, value) {
        parsedColorDesignImages[key.toString()] = value.toString();
      });
    } else if (json['design_image'] != null || json['designImage'] != null) {
      // Backwards compatibility for old single design image
      final String oldDesign = json['design_image']?.toString() ?? json['designImage']?.toString() ?? '';
      if (oldDesign.isNotEmpty) {
        parsedColorDesignImages['Black'] = oldDesign; 
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'UNKNOWN PRODUCT',
      price: json['price']?.toString() ?? '₹0.00',
      originalPrice: json['original_price']?.toString() ?? json['originalPrice']?.toString(),
      description: json['description']?.toString(),
      image: json['image']?.toString(),
      images: parsedImages,
      colorImages: parsedColorImages,
      colorDesignImages: parsedColorDesignImages,
      mockup: json['mockup']?.toString(),
      tag: json['tag']?.toString(),
      gender: json['gender']?.toString() ?? 'mens',
      category: json['category']?.toString() ?? 'design',
      isFavorite: json['is_favorite'] == true || json['isFavorite'] == true,
    );
  }


  /// Convert to Map for serialization if needed (e.g. adding to cart)
  Map<String, String> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'gender': gender,
      'category': category,
      if (originalPrice != null) 'originalPrice': originalPrice!,
      if (description != null) 'description': description!,
      if (image != null) 'image': image!,
      if (images.isNotEmpty) 'images': images.join('||'),
      if (colorImages.isNotEmpty) 'colorImages': _encodeColorImages(colorImages),
      if (colorDesignImages.isNotEmpty) 'colorDesignImages': _encodeColorDesignImages(colorDesignImages),
      if (mockup != null) 'mockup': mockup!,
      if (tag != null) 'tag': tag!,
      'isFavorite': isFavorite.toString(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        originalPrice,
        description,
        image,
        images,
        colorImages,
        colorDesignImages,
        mockup,
        tag,
        gender,
        category,
        isFavorite,
      ];
}
