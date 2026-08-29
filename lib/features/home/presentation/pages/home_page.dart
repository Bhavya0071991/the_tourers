import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../product/providers/product_provider.dart';

import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/constants/app_sizes.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_section.dart';
import '../widgets/promo_banner.dart';
import '../widgets/trending_gear_grid.dart';
import '../widgets/shop_by_collection_section.dart';
import '../widgets/footer_section.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black87.withValues(alpha: 0.9),
      body: Column(
        children: [
          // The top web promo banner
          const PromoBanner(),

          // Standard E-commerce App Bar (Solid, top of the page)
          const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),

          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(paginatedProductsProvider);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // The Hero Section below the app bar
                    const HeroSection(),

                    // Below the fold sections
                    SizedBox(
                      width: double.infinity,
                      child: const Column(
                        children: [
                          // Product Grid (Constrained Width for Web)
                          WebConstrainedBox(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSizes.p24,
                            ),
                            child: TrendingGearGrid(),
                          ),

                          // Shop by Collection Section
                          ShopByCollectionSection(),

                          // Bottom spacing
                          SizedBox(height: AppSizes.p64),

                          // The new Brutalist Footer
                          FooterSection(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
