import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/promo_marquee.dart';
import '../data/repositories/promo_marquee_repository.dart';

final promoMarqueeProvider = FutureProvider<PromoMarquee?>((ref) async {
  final repository = ref.watch(promoMarqueeRepositoryProvider);
  return await repository.getMarquee();
});
