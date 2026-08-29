import 'package:flutter_riverpod/flutter_riverpod.dart';

// In a real application, this would fetch from an API or database.
final promoBannerProvider = FutureProvider<List<String>>((ref) async {
  // Simulate a network delay
  await Future.delayed(const Duration(seconds: 1));

  return [
    'HIMACHAL DAY SALE 50% OFF',
    'FREE SHIPPING ABOVE ₹699',
    'NEW ARRIVAL',
  ];
});
