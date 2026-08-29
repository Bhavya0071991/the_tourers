import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/promo_marquee.dart';

final promoMarqueeRepositoryProvider = Provider<PromoMarqueeRepository>((ref) {
  return PromoMarqueeRepository(ref.watch(supabaseClientProvider));
});

class PromoMarqueeRepository {
  final SupabaseClient _supabase;

  PromoMarqueeRepository(this._supabase);

  Future<PromoMarquee?> getMarquee() async {
    final response = await _supabase
        .from('promo_marquee')
        .select()
        .eq('id', 1)
        .maybeSingle();

    if (response == null) return null;
    return PromoMarquee.fromJson(response);
  }

  Future<void> updateMarquee(PromoMarquee marquee) async {
    await _supabase
        .from('promo_marquee')
        .upsert({
          'id': 1,
          ...marquee.toJson(),
        });
  }
}
