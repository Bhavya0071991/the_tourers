import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/datasources/review_remote_data_source.dart';
import '../data/models/review_model.dart';
import 'package:uuid/uuid.dart';

final reviewRemoteDataSourceProvider = Provider<ReviewRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ReviewRemoteDataSource(supabase);
});

// Provider to fetch reviews for a specific product
final productReviewsProvider = FutureProvider.family<List<ReviewModel>, String>(
  (ref, productId) async {
    final dataSource = ref.watch(reviewRemoteDataSourceProvider);
    return dataSource.getReviewsForProduct(productId);
  },
);

final reviewSubmitProvider =
    AsyncNotifierProvider<ReviewSubmitNotifier, void>(() {
      return ReviewSubmitNotifier();
    });

class ReviewSubmitNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitReview({
    required String productId,
    required int rating,
    required String comment,
    required List<XFile> images,
    ReviewModel? existingReview,
  }) async {
    state = const AsyncLoading();

    try {
      final authState = ref.read(authProvider).value;
      if (authState == null || authState.status == AuthStatus.unauthenticated || authState.id == null) {
        throw Exception('You must be logged in to leave a review.');
      }

      final dataSource = ref.read(reviewRemoteDataSourceProvider);

      if (existingReview != null) {
        final review = ReviewModel(
          id: existingReview.id,
          productId: productId,
          userId: authState.id!,
          userName: authState.username ?? authState.email?.split('@')[0] ?? 'Anonymous',
          rating: rating,
          comment: comment,
          imageUrls: existingReview.imageUrls,
          createdAt: existingReview.createdAt,
        );
        await dataSource.updateReview(review, images);
      } else {
        final review = ReviewModel(
          id: const Uuid().v4(),
          productId: productId,
          userId: authState.id!,
          userName: authState.username ?? authState.email?.split('@')[0] ?? 'Anonymous',
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        );
        await dataSource.addReview(review, images);
      }

      // Invalidate the reviews provider for this product so it fetches the new review
      ref.invalidate(productReviewsProvider(productId));

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
