import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../providers/review_provider.dart';
import '../../data/models/review_model.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class WriteReviewSheet extends ConsumerStatefulWidget {
  final String productId;

  const WriteReviewSheet({super.key, required this.productId});

  @override
  ConsumerState<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends ConsumerState<WriteReviewSheet> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  ReviewModel? _existingReview;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _checkExistingReview();
      _isInit = true;
    }
  }

  Future<void> _checkExistingReview() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;

    try {
      // await the future to ensure we get fresh data if it was just invalidated
      final reviews = await ref.read(productReviewsProvider(widget.productId).future);
      final existing = reviews.firstWhere((r) => r.userId == user.id);
      
      if (mounted) {
        setState(() {
          _existingReview = existing;
          _rating = existing.rating;
          _commentController.text = existing.comment ?? '';
        });
      }
    } catch (_) {
      // No existing review found or error fetching
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> picked = await _picker.pickMultiImage();
      if (picked.isNotEmpty) {
        setState(() {
          _images.addAll(picked);
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.show(context, 'Failed to pick images: $e', isError: true);
      }
    }
  }

  void _submitReview() async {
    if (_rating == 0) {
      AppSnackBar.show(context, 'Please select a star rating.', isError: true);
      return;
    }

    await ref.read(reviewSubmitProvider.notifier).submitReview(
          productId: widget.productId,
          rating: _rating,
          comment: _commentController.text.trim(),
          images: _images,
          existingReview: _existingReview,
        );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final submitState = ref.watch(reviewSubmitProvider);

    ref.listen<AsyncValue<void>>(reviewSubmitProvider, (previous, next) {
      next.when(
        data: (_) {
          AppSnackBar.show(context, 'Review submitted successfully!');
          Navigator.of(context).pop();
        },
        error: (error, _) {
          AppSnackBar.show(context, error.toString(), isError: true);
        },
        loading: () {},
      );
    });

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: textColor, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bebas(
                  'WRITE A REVIEW',
                  fontSize: 24,
                  color: textColor,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Star Rating
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: index < _rating ? Colors.amber : textColor.withValues(alpha: 0.2),
                      size: 40,
                    ),
                    onPressed: submitState.isLoading
                        ? null
                        : () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                  );
                }),
              ),
            ),
            const SizedBox(height: 24),
            
            // Comment Box
            TextField(
              controller: _commentController,
              maxLines: 4,
              enabled: !submitState.isLoading,
              style: GoogleFonts.spaceMono(fontSize: 12, color: textColor),
              decoration: InputDecoration(
                hintText: 'Share your experience with this product...',
                hintStyle: GoogleFonts.spaceMono(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.4),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: textColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Photo Upload
            if (_images.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 80,
                          decoration: BoxDecoration(
                            border: Border.all(color: textColor),
                          ),
                          child: kIsWeb
                              ? Image.network(_images[index].path, fit: BoxFit.cover)
                              : Image.file(File(_images[index].path), fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: GestureDetector(
                            onTap: submitState.isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _images.removeAt(index);
                                    });
                                  },
                            child: Container(
                              color: Colors.red,
                              child: const Icon(Icons.close, color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            OutlinedButton.icon(
              onPressed: submitState.isLoading ? null : _pickImages,
              icon: const Icon(Icons.add_a_photo, size: 16),
              label: AppText.spaceMono('ADD PHOTOS', fontSize: 12),
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: textColor.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Submit Button
            BrutalistHoverWidget(
              shadowColor: textColor.withValues(alpha: 0.15),
              offset: const Offset(4, 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitState.isLoading ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: textColor,
                    foregroundColor: Theme.of(context).colorScheme.surface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  ),
                  child: submitState.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.surface),
                          ),
                        )
                      : AppText.bebas(_existingReview != null ? 'UPDATE REVIEW' : 'SUBMIT REVIEW', fontSize: 16, letterSpacing: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
