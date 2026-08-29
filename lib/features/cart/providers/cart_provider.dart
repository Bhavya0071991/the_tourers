import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/supabase_client.dart';

class CartNotifier extends AsyncNotifier<List<CartItem>> {
  @override
  Future<List<CartItem>> build() async {
    return _fetchCart();
  }

  Future<List<CartItem>> _fetchCart() async {
    final user = ref.watch(authProvider).value;
    if (user == null || user.status != AuthStatus.authenticated) {
      return []; // Return empty for unauthenticated users
    }

    final response = await ref
        .read(supabaseClientProvider)
        .from('cart_items')
        .select()
        .eq('user_id', user.id!)
        .order('created_at', ascending: false);

    return (response as List).map((json) => CartItem.fromJson(json)).toList();
  }

  Future<void> addItem(
    Map<String, String> product,
    String size, {
    String? customText,
    String? frontDesignPreview,
    String? backDesignPreview,
    String? frontPrintUrl,
    String? backPrintUrl,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.status != AuthStatus.authenticated) {
      throw Exception('User must be logged in to add to cart.');
    }

    final currentItems = state.value ?? [];

    // Check if an identical item exists (same product, size, and design details)
    final existingIndex = currentItems.indexWhere(
      (item) =>
          item.product['id'] == product['id'] &&
          item.size == size &&
          item.customText == customText &&
          item.frontDesignPreview == frontDesignPreview &&
          item.backDesignPreview == backDesignPreview &&
          item.frontPrintUrl == frontPrintUrl &&
          item.backPrintUrl == backPrintUrl,
    );

    try {
      if (existingIndex >= 0) {
        final existingItem = currentItems[existingIndex];
        final newQuantity = existingItem.quantity + 1;

        await ref
            .read(supabaseClientProvider)
            .from('cart_items')
            .update({'quantity': newQuantity})
            .eq('id', existingItem.id);
      } else {
        // Create a new temporary item without ID for toJson
        final newItem = CartItem(
          id: '', // Supabase generates this
          product: product,
          size: size,
          customText: customText,
          quantity: 1,
          frontDesignPreview: frontDesignPreview,
          backDesignPreview: backDesignPreview,
          frontPrintUrl: frontPrintUrl,
          backPrintUrl: backPrintUrl,
        );

        await ref
            .read(supabaseClientProvider)
            .from('cart_items')
            .insert(newItem.toJson(user.id!));
      }

      // Refresh the state after update/insert
      state = AsyncData(await _fetchCart());
    } catch (e) {
      // Re-throw to be handled by the UI
      throw Exception('Failed to add item to cart: $e');
    }
  }

  Future<void> updateQuantity(String id, int quantity) async {
    if (quantity <= 0) {
      return removeItem(id);
    }

    try {
      await ref
          .read(supabaseClientProvider)
          .from('cart_items')
          .update({'quantity': quantity})
          .eq('id', id);

      state = AsyncData(await _fetchCart());
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  Future<void> removeItem(String id) async {
    try {
      await ref
          .read(supabaseClientProvider)
          .from('cart_items')
          .delete()
          .eq('id', id);

      state = AsyncData(await _fetchCart());
    } catch (e) {
      throw Exception('Failed to remove item: $e');
    }
  }

  Future<void> clearCart() async {
    final user = ref.read(authProvider).value;
    if (user == null || user.status != AuthStatus.authenticated) return;

    try {
      await ref
          .read(supabaseClientProvider)
          .from('cart_items')
          .delete()
          .eq('user_id', user.id!);

      state = const AsyncData([]);
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartItemCountProvider = Provider<int>((ref) {
  final cartItemsAsync = ref.watch(cartProvider);
  return cartItemsAsync.value?.fold(
        0,
        (sum, item) => (sum ?? 0) + item.quantity,
      ) ??
      0;
});

final cartTotalPriceProvider = Provider<double>((ref) {
  final cartItemsAsync = ref.watch(cartProvider);
  return cartItemsAsync.value?.fold(
        0.0,
        (sum, item) => (sum ?? 0.0) + item.totalPrice,
      ) ??
      0.0;
});
