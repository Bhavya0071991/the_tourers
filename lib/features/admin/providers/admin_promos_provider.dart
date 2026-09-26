import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final adminPromosProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final response = await Supabase.instance.client
      .from('promo_codes')
      .select()
      .order('created_at', ascending: false);
      
  return List<Map<String, dynamic>>.from(response);
});
