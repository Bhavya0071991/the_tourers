import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final int rating;
  final String? comment;
  final List<String> imageUrls;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.comment,
    this.imageUrls = const [],
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      imageUrls: json['image_urls'] != null 
          ? List<String>.from(json['image_urls']) 
          : [],
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && !id.startsWith('temp_')) 'id': id,
      'product_id': productId,
      'user_id': userId,
      'user_name': userName,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      // created_at is handled by DB defaults for inserts, but we can send it
      if (id.isNotEmpty && !id.startsWith('temp_')) 
         'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        rating,
        comment,
        imageUrls,
        createdAt,
      ];
}
