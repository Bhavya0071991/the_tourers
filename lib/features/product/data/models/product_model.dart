import 'dart:convert';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    super.originalPrice,
    super.description,
    super.image,
    super.images = const [],
    super.colorImages = const {},
    super.colorDesignImages = const {},
    super.mockup,
    super.tag,
    required super.gender,
    required super.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Supabase stores arrays as List<dynamic>
    List<String> parsedImages = [];
    if (json['images'] != null) {
      parsedImages = List<String>.from(json['images']);
    }

    Map<String, List<String>> parsedColorImages = {};
    if (json['color_images'] != null) {
      Map? map;
      if (json['color_images'] is String) {
        try {
          map = jsonDecode(json['color_images']) as Map?;
        } catch (e) {
          // Ignore parse errors
        }
      } else if (json['color_images'] is Map) {
        map = json['color_images'] as Map;
      }
      
      if (map != null) {
        map.forEach((key, value) {
          if (value is List) {
            parsedColorImages[key.toString()] = value.map((e) => e.toString()).toList();
          }
        });
      }
    }

    Map<String, String> parsedColorDesignImages = {};
    if (json['color_design_images'] != null) {
      Map? map;
      if (json['color_design_images'] is String) {
        try {
          map = jsonDecode(json['color_design_images']) as Map?;
        } catch (e) {}
      } else if (json['color_design_images'] is Map) {
        map = json['color_design_images'] as Map;
      }
      if (map != null) {
        map.forEach((key, value) {
          parsedColorDesignImages[key.toString()] = value.toString();
        });
      }
    } else if (json['design_image'] != null) {
      final oldDesign = json['design_image'].toString();
      if (oldDesign.isNotEmpty) {
         parsedColorDesignImages['Black'] = oldDesign;
      }
    }

    // Format price if it comes as a number from DB, or if it's already a string
    String formattedPrice = json['price']?.toString() ?? '0';
    if (!formattedPrice.startsWith('₹')) {
      formattedPrice = '₹$formattedPrice';
    }

    String? formattedOriginalPrice;
    if (json['original_price'] != null) {
      formattedOriginalPrice = json['original_price'].toString();
      if (!formattedOriginalPrice.startsWith('₹')) {
        formattedOriginalPrice = '₹$formattedOriginalPrice';
      }
    }

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: formattedPrice,
      originalPrice: formattedOriginalPrice,
      description: json['description'] as String?,
      image: json['image'] as String?,
      images: parsedImages,
      colorImages: parsedColorImages,
      colorDesignImages: parsedColorDesignImages,
      mockup: json['mockup'] as String?,
      tag: json['tag'] as String?,
      gender: json['gender'] as String,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    // Strip the ₹ symbol for storing as numeric in Supabase
    String cleanPrice = price.replaceAll('₹', '').replaceAll(',', '');
    String? cleanOriginalPrice = originalPrice
        ?.replaceAll('₹', '')
        .replaceAll(',', '');

    return {
      if (id.isNotEmpty && !id.startsWith('prod_'))
        'id': id, // Supabase auto-generates uuid if not provided
      'name': name,
      'price': double.tryParse(cleanPrice) ?? 0.0,
      'original_price': cleanOriginalPrice != null
          ? double.tryParse(cleanOriginalPrice)
          : null,
      'description': description,
      'image': image,
      'images': images,
      'color_images': colorImages,
      'color_design_images': colorDesignImages,
      'mockup': mockup,
      'tag': tag,
      'gender': gender,
      'category': category,
    };
  }
}
