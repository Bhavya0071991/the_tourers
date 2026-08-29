import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/home_banner.dart';
import '../data/repositories/home_banner_repository.dart';

final homeBannersProvider = FutureProvider<List<HomeBanner>>((ref) async {
  final repository = ref.watch(homeBannerRepositoryProvider);
  return await repository.getActiveBanners();
});

final allHomeBannersProvider = FutureProvider<List<HomeBanner>>((ref) async {
  final repository = ref.watch(homeBannerRepositoryProvider);
  return await repository.getAllBanners();
});
