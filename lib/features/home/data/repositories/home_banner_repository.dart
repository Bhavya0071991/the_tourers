import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/network/supabase_client.dart';
import '../models/home_banner.dart';
import 'dart:typed_data';

final homeBannerRepositoryProvider = Provider<HomeBannerRepository>((ref) {
  return HomeBannerRepository(ref.watch(supabaseClientProvider));
});

class HomeBannerRepository {
  final SupabaseClient _supabase;

  HomeBannerRepository(this._supabase);

  Future<List<HomeBanner>> getActiveBanners() async {
    final response = await _supabase
        .from('home_banners')
        .select()
        .eq('is_active', true)
        .order('order_index', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).map((e) => HomeBanner.fromJson(e)).toList();
  }

  Future<List<HomeBanner>> getAllBanners() async {
    final response = await _supabase
        .from('home_banners')
        .select()
        .order('order_index', ascending: true)
        .order('created_at', ascending: false);

    return (response as List).map((e) => HomeBanner.fromJson(e)).toList();
  }

  Future<HomeBanner> createBanner(HomeBanner banner) async {
    final response = await _supabase
        .from('home_banners')
        .insert(banner.toJson())
        .select()
        .single();

    return HomeBanner.fromJson(response);
  }

  Future<HomeBanner> updateBanner(HomeBanner banner) async {
    final response = await _supabase
        .from('home_banners')
        .update(banner.toJson())
        .eq('id', banner.id)
        .select()
        .single();

    return HomeBanner.fromJson(response);
  }

  Future<void> deleteBanner(String id) async {
    await _supabase.from('home_banners').delete().eq('id', id);
  }

  Future<String> uploadBannerImage(
    Uint8List imageBytes,
    String fileName, {
    String contentType = 'image/jpeg',
  }) async {
    final filePath = 'banners/$fileName';
    await _supabase.storage
        .from('banners')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return _supabase.storage.from('banners').getPublicUrl(filePath);
  }
}
