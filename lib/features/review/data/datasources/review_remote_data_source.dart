import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/review_model.dart';
import 'package:uuid/uuid.dart';

class ReviewRemoteDataSource {
  final SupabaseClient _supabase;
  final _uuid = const Uuid();

  ReviewRemoteDataSource(this._supabase);

  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    final response = await _supabase
        .from('product_reviews')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false)
        .limit(50);

    return (response as List)
        .map((json) => ReviewModel.fromJson(json))
        .toList();
  }

  Future<ReviewModel> addReview(ReviewModel review, List<XFile> images) async {
    List<String> imageUrls = [];

    // Upload images if any
    for (var i = 0; i < images.length; i++) {
      final file = images[i];
      final ext = file.name.split('.').last;
      final fileName = '${_uuid.v4()}.$ext';
      final path = '${review.productId}/$fileName';

      final bytes = await file.readAsBytes();
      await _supabase.storage.from('review_images').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$ext'),
      );
      
      final publicUrl = _supabase.storage.from('review_images').getPublicUrl(path);
      imageUrls.add(publicUrl);
    }

    // Insert review to database
    final reviewData = review.toJson();
    reviewData['image_urls'] = imageUrls;

    final response = await _supabase
        .from('product_reviews')
        .insert(reviewData)
        .select()
        .single();

    return ReviewModel.fromJson(response);
  }

  Future<ReviewModel> updateReview(ReviewModel review, List<XFile> newImages) async {
    List<String> imageUrls = List.from(review.imageUrls);

    // Upload new images if any
    for (var i = 0; i < newImages.length; i++) {
      final file = newImages[i];
      final ext = file.name.split('.').last;
      final fileName = '${_uuid.v4()}.$ext';
      final path = '${review.productId}/$fileName';

      final bytes = await file.readAsBytes();
      await _supabase.storage.from('review_images').uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(contentType: 'image/$ext'),
      );
      
      final publicUrl = _supabase.storage.from('review_images').getPublicUrl(path);
      imageUrls.add(publicUrl);
    }

    // Update review in database
    final reviewData = review.toJson();
    reviewData['image_urls'] = imageUrls;
    
    // Ensure we don't try to update id or created_at if they shouldn't be
    reviewData.remove('id');
    reviewData.remove('created_at');

    final response = await _supabase
        .from('product_reviews')
        .update(reviewData)
        .eq('id', review.id)
        .select()
        .single();

    return ReviewModel.fromJson(response);
  }
}
