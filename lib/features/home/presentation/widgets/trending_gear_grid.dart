import 'package:dummy_epod/core/widgets/app_text.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../../../../core/widgets/fade_in_slide_widget.dart';
import '../../../product/presentation/widgets/product_card.dart';
import '../../../product/providers/product_provider.dart';

class TrendingGearGrid extends ConsumerStatefulWidget {
  const TrendingGearGrid({super.key});

  @override
  ConsumerState<TrendingGearGrid> createState() => _TrendingGearGridState();
}

class _TrendingGearGridState extends ConsumerState<TrendingGearGrid> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    } else if (screenWidth <= 550) {
      crossAxisCount = 1;
    }

    final productsAsync = ref.watch(
      paginatedProductsProvider(const ProductFilter()),
    );

    return WebConstrainedBox(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth > 900 ? 64.0 : 16.0,
        vertical: AppSizes.p64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.bebas(
            AppStrings.latestCollection,
            fontSize: screenWidth > 900 ? 64 : 42,
            letterSpacing: 2.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),

          // Divider Line
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Divider(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
              thickness: 1,
            ),
          ),

          // Grid
          productsAsync.when(
            data: (state) {
              // Show only a few latest products on the home page
              final products = state.products.take(8).toList();

              if (products.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Text(
                      'NO TRENDING PRODUCTS FOUND',
                      style: GoogleFonts.spaceMono(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.78,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 28,
                ),
                itemBuilder: (context, index) {
                  return FadeInSlideWidget(
                    delay: Duration(milliseconds: index * 100),
                    child: ProductCard(product: products[index]),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(64.0),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'Error loading products: $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
