import '../../product/domain/entities/product.dart';

class WishlistItem {
  final String id;
  final String userId;
  final String productId;
  final Product? product;
  final DateTime createdAt;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.productId,
    this.product,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String,
      product: json['products'] != null 
          ? Product.fromJson(json['products'] as Map<String, dynamic>) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'].toString()) 
          : DateTime.now(),
    );
  }
}
