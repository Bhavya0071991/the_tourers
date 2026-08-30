import 'package:flutter/material.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/web_constrained_box.dart';
import '../widgets/product_card.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../home/presentation/widgets/custom_app_bar.dart';
import '../../../home/presentation/widgets/footer_section.dart';
import '../../../home/presentation/widgets/promo_banner.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../providers/product_provider.dart';

final categoryFilterProvider = StateProvider.autoDispose.family<String, String>(
  (ref, category) => 'ALL',
);

class CategoryPage extends ConsumerWidget {
  final String category; // 'mens' or 'womens'

  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(categoryFilterProvider(category));
    final filters = const ['ALL', 'DESIGNS', 'QUOTES'];
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    String? mapFilterToCategory(String filter) {
      switch (filter) {
        case 'DESIGNS':
          return 'design';
        case 'QUOTES':
          return 'quotes';
        default:
          return null;
      }
    }

    // Filter products based on category route and active selection
    final filter = ProductFilter(
      gender: category.toLowerCase(),
      category: mapFilterToCategory(selectedFilter),
    );
    final productsAsync = ref.watch(paginatedProductsProvider(filter));

    int crossAxisCount = 2;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 3;
    } else if (screenWidth <= 550) {
      crossAxisCount = 2;
    }

    final categoryTitle = category == 'mens'
        ? AppStrings.mensCategoryTitle
        : AppStrings.womensCategoryTitle;
    final categorySubtitle = category == 'mens'
        ? AppStrings.mensCategoryDesc
        : AppStrings.womensCategoryDesc;

    return Scaffold(
      body: Column(
        children: [
          // Top promo marquee banner
          const PromoBanner(),

          // Consistent Brutalist Nav Bar
          const WebConstrainedBox(child: CustomAppBar(isTransparent: false)),

          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
                  ref
                      .read(paginatedProductsProvider(filter).notifier)
                      .loadMore();
                }
                return false;
              },
              child: CustomScrollView(
                key: ValueKey(category),
                slivers: [
                  SliverToBoxAdapter(
                    child: WebConstrainedBox(
                      padding: EdgeInsets.only(
                        left: isDesktop ? 64.0 : 24.0,
                        right: isDesktop ? 64.0 : 24.0,
                        top: isDesktop ? 48.0 : 32.0,
                        bottom: isDesktop ? 48.0 : 12.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Giant Header Title
                          AppText.bebas(
                            categoryTitle,
                            fontSize: isDesktop ? 96 : 42,
                            height: 0.9,
                            letterSpacing: 4.0,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: AppSizes.p16),

                          // Description Subtitle matching brutalist constraints
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: AppText.spaceMono(
                              categorySubtitle,
                              fontSize: isDesktop ? 16 : 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: AppSizes.p48),

                          // Filter Row - Custom Interactive Brutalist Chips
                          AppText.spaceMono(
                            AppStrings.filterCategoryMarquee,
                            fontSize: isDesktop ? 14 : 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: AppSizes.p16),

                          // Horizontal scrollable brutalist chip filters
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: filters.map((f) {
                                final isSelected = f == selectedFilter;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    right: 16.0,
                                    bottom: 8.0,
                                  ),
                                  child: InkWell(
                                    onTap: () =>
                                        ref
                                                .read(
                                                  categoryFilterProvider(
                                                    category,
                                                  ).notifier,
                                                )
                                                .state =
                                            f,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isDesktop ? 28.0 : 20.0,
                                        vertical: isDesktop ? 16.0 : 12.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.onSurface
                                            : Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          width: 3.0,
                                        ),
                                      ),
                                      child: AppText.spaceMono(
                                        f,
                                        fontSize: isDesktop ? 14 : 12,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.surface
                                            : Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSizes.p32),

                          // Product Count indicator
                          productsAsync.maybeWhen(
                            data: (state) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText.spaceMono(
                                  AppStrings.showingProducts.replaceAll(
                                    '%s',
                                    state.products.length.toString(),
                                  ),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                Container(
                                  height: 2,
                                  width: 100,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                                ),
                              ],
                            ),
                            orElse: () => const SizedBox.shrink(),
                          ),
                          SizedBox(height: isDesktop ? AppSizes.p32 : AppSizes.p8),
                        ],
                      ),
                    ),
                  ),

                  productsAsync.when(
                    data: (state) {
                      if (state.products.isEmpty && !state.isLoadingMore) {
                        return SliverToBoxAdapter(
                          child: WebConstrainedBox(
                            padding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 64.0 : 24.0,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 80.0,
                                horizontal: 24.0,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  width: 3.0,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_outlined,
                                    size: 48,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 24),
                                  AppText.bebas(
                                    "NO RESULTS // FILTER EMPTY",
                                    fontSize: 32,
                                    letterSpacing: 2.0,
                                  ),
                                  const SizedBox(height: 12),
                                  AppText.spaceMono(
                                    "NO PRODUCTS MATCH YOUR CURRENT FILTER CRITERIA.",
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(height: 32),
                                  BrutalistHoverWidget(
                                    shadowColor: AppTheme.neonAccent,
                                    offset: const Offset(4, 4),
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          ref
                                                  .read(
                                                    categoryFilterProvider(
                                                      category,
                                                    ).notifier,
                                                  )
                                                  .state =
                                              'ALL',
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 32,
                                          vertical: 16,
                                        ),
                                      ),
                                      child: AppText.bebas(
                                        "CLEAR FILTERS ↗",
                                        fontSize: 18,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth <= 550 ? 8.0 : (isDesktop ? 64.0 : 24.0),
                        ),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: screenWidth <= 550 ? 0.70 : 0.78,
                                crossAxisSpacing: screenWidth <= 550 ? 12 : 20,
                                mainAxisSpacing: screenWidth <= 550 ? 16 : 28,
                              ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index == state.products.length) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              return ProductCard(
                                product: state.products[index],
                              );
                            },
                            childCount:
                                state.products.length +
                                (state.isLoadingMore ? 1 : 0),
                          ),
                        ),
                      );
                    },
                    loading: () => const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => SliverToBoxAdapter(
                      child: Center(child: Text('Error: $err')),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48.0),
                      child: FooterSection(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
