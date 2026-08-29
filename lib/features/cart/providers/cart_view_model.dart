import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  String applyPromoCode(String code) {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode == 'TOURER15') {
      state = state.copyWith(
        discountPercentage: 0.15,
        isPromoApplied: true,
        appliedPromoCode: cleanCode,
      );
      return 'PROMO CODE APPLIED: 15% DISCOUNT GRANTED!';
    } else if (cleanCode == 'ANTIGRAVITY') {
      state = state.copyWith(
        discountPercentage: 0.20,
        isPromoApplied: true,
        appliedPromoCode: cleanCode,
      );
      return 'PROMO CODE APPLIED: 20% LAB DISCOUNT GRANTED!';
    } else {
      return 'ERROR: PROMO CODE EXPIRED OR INVALID';
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
