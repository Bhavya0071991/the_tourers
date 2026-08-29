import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';
import '../models/delivery_method.dart';
import './address_provider.dart';
import './delivery_provider.dart';
import '../../cart/providers/cart_provider.dart';

enum CheckoutStatus { idle, processing, success, error }

class CheckoutState {
  final Address? selectedAddress;
  final DeliveryMethod? selectedDelivery;
  final String? selectedPaymentMethod;
  final CheckoutStatus status;
  final String? errorMessage;
  final double discountPercentage;

  const CheckoutState({
    this.selectedAddress,
    this.selectedDelivery,
    this.selectedPaymentMethod,
    this.status = CheckoutStatus.idle,
    this.errorMessage,
    this.discountPercentage = 0.0,
  });

  CheckoutState copyWith({
    Address? selectedAddress,
    DeliveryMethod? selectedDelivery,
    String? selectedPaymentMethod,
    CheckoutStatus? status,
    String? errorMessage,
    double? discountPercentage,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedDelivery: selectedDelivery ?? this.selectedDelivery,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
      status: status ?? this.status,
      errorMessage: errorMessage,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    final address = ref.watch(selectedAddressProvider);
    final delivery = ref.watch(selectedDeliveryProvider);
    return CheckoutState(
      selectedAddress: address,
      selectedDelivery: delivery,
    );
  }

  void setAddress(Address address) {
    state = state.copyWith(selectedAddress: address);
  }

  void setDelivery(DeliveryMethod delivery) {
    state = state.copyWith(selectedDelivery: delivery);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void setDiscount(double percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  Future<void> processPayment() async {
    state = state.copyWith(status: CheckoutStatus.processing);
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(status: CheckoutStatus.success);
  }

  void reset() {
    state = const CheckoutState();
  }
}

final checkoutProvider =
    NotifierProvider<CheckoutNotifier, CheckoutState>(CheckoutNotifier.new);

/// Computed pricing providers
final checkoutSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartTotalPriceProvider);
});

final checkoutDiscountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(checkoutSubtotalProvider);
  final checkout = ref.watch(checkoutProvider);
  return subtotal * checkout.discountPercentage;
});

final checkoutDeliveryChargeProvider = Provider<double>((ref) {
  final checkout = ref.watch(checkoutProvider);
  return checkout.selectedDelivery?.charge ?? 0.0;
});

final checkoutGstProvider = Provider<double>((ref) {
  final subtotal = ref.watch(checkoutSubtotalProvider);
  final discount = ref.watch(checkoutDiscountProvider);
  return (subtotal - discount) * 0.18; // 18% GST
});

final checkoutTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(checkoutSubtotalProvider);
  final discount = ref.watch(checkoutDiscountProvider);
  final delivery = ref.watch(checkoutDeliveryChargeProvider);
  final gst = ref.watch(checkoutGstProvider);
  return subtotal - discount + delivery + gst;
});
