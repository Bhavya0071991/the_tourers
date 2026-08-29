import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/supabase_client.dart';
import '../models/wishlist_item.dart';
import 'package:uuid/uuid.dart';

class WishlistNotifier extends AsyncNotifier<List<WishlistItem>> {
  @override
  Future<List<WishlistItem>> build() async {
    return _fetchWishlist();
  }

  Future<List<WishlistItem>> _fetchWishlist() async {
    final user = ref.read(authProvider).value;
    if (user == null || user.status != AuthStatus.authenticated || user.id == null) {
      return [];
    }

    try {
      final response = await ref.read(supabaseClientProvider)
          .from('wishlists')
          .select('*, products(*)')
          .eq('user_id', user.id!)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => WishlistItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching wishlist: $e');
      return [];
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.status != AuthStatus.authenticated || user.id == null) {
      throw Exception('Must be logged in to modify wishlist');
    }

    final prev = state.value ?? [];
    final isWishlisted = prev.any((item) => item.productId == productId);

    if (isWishlisted) {
      // Optimistic removal
      state = AsyncData(prev.where((item) => item.productId != productId).toList());
      
      try {
        await ref.read(supabaseClientProvider)
            .from('wishlists')
            .delete()
            .eq('user_id', user.id!)
            .eq('product_id', productId);
      } catch (e) {
        // Revert on failure
        state = AsyncData(prev);
        print('Error removing from wishlist: $e');
      }
    } else {
      // Optimistic addition (without product data initially, it will fetch on next load or we can just mock it)
      final tempId = const Uuid().v4();
      final tempItem = WishlistItem(
        id: tempId,
        userId: user.id!,
        productId: productId,
        createdAt: DateTime.now(),
      );
      
      state = AsyncData([tempItem, ...prev]);

      try {
        await ref.read(supabaseClientProvider)
            .from('wishlists')
            .insert({
              'user_id': user.id!,
              'product_id': productId,
            });
            
        // Refresh to get the nested product data
        state = AsyncData(await _fetchWishlist());
      } catch (e) {
        // Revert on failure
        state = AsyncData(prev);
        print('Error adding to wishlist: $e');
      }
    }
  }
  
  bool isWishlisted(String productId) {
    final currentList = state.value ?? [];
    return currentList.any((item) => item.productId == productId);
  }
}

final wishlistProvider = AsyncNotifierProvider<WishlistNotifier, List<WishlistItem>>(() {
  return WishlistNotifier();
});
