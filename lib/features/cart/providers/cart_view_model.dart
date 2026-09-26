import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartViewState {
  final double discountPercentage;
  final bool isPromoApplied;
  final String appliedPromoCode;

  const CartViewState({
    this.discountPercentage = 0.0,
    this.isPromoApplied = false,
    this.appliedPromoCode = '',
  });

  CartViewState copyWith({
    double? discountPercentage,
    bool? isPromoApplied,
    String? appliedPromoCode,
  }) {
    return CartViewState(
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isPromoApplied: isPromoApplied ?? this.isPromoApplied,
      appliedPromoCode: appliedPromoCode ?? this.appliedPromoCode,
    );
  }
}

class CartViewModel extends Notifier<CartViewState> {
  @override
  CartViewState build() {
    return const CartViewState();
  }

  Future<String> applyPromoCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return 'ERROR: PLEASE ENTER A PROMO CODE';

    try {
      final response = await Supabase.instance.client
          .from('promo_codes')
          .select()
          .eq('code', cleanCode)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        return 'ERROR: PROMO CODE EXPIRED OR INVALID';
      }

      // Check expiry date
      if (response['expiry_date'] != null) {
        final expiry = DateTime.parse(response['expiry_date']);
        if (DateTime.now().isAfter(expiry)) {
          return 'ERROR: PROMO CODE HAS EXPIRED';
        }
      }

      // Check usage limit
      if (response['usage_limit'] != null) {
        final usageLimit = response['usage_limit'] as int;
        final timesUsed = response['times_used'] as int? ?? 0;
        if (timesUsed >= usageLimit) {
          return 'ERROR: PROMO CODE USAGE LIMIT REACHED';
        }
      }

      final discountPercentage = (response['discount_percentage'] as num).toDouble();

      state = state.copyWith(
        discountPercentage: discountPercentage / 100.0,
        isPromoApplied: true,
        appliedPromoCode: cleanCode,
      );

      return 'PROMO CODE APPLIED: ${discountPercentage.toStringAsFixed(0)}% DISCOUNT GRANTED!';
    } catch (e) {
      return 'ERROR: FAILED TO VERIFY PROMO CODE';
    }
  }

  String removePromoCode() {
    state = const CartViewState();
    return 'PROMO CODE REMOVED';
  }
}

final cartViewModelProvider = NotifierProvider<CartViewModel, CartViewState>(() {
  return CartViewModel();
});
