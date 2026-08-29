import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_paths.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../product/providers/product_provider.dart';
import '../../../product/domain/entities/product.dart';
import '../../../../core/widgets/app_image.dart';

class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  String _selectedFilter = 'ALL';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final filter = ProductFilter(
        gender: _selectedFilter == 'ALL' ? null : _selectedFilter.toLowerCase(),
      );
      ref.read(paginatedProductsProvider(filter).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    final filter = ProductFilter(
      gender: _selectedFilter == 'ALL' ? null : _selectedFilter.toLowerCase(),
    );
    final productsAsync = ref.watch(paginatedProductsProvider(filter));

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText.bebas(
                  'PRODUCTS',
                  fontSize: 48,
                  letterSpacing: 2.0,
                  color: textColor,
                ),
                BrutalistHoverWidget(
                  shadowColor: textColor.withValues(alpha: 0.2),
                  offset: const Offset(4, 4),
                  child: ElevatedButton.icon(
                    onPressed: () => context.go(AppPaths.adminAddProduct),
                    icon: Icon(Icons.add, color: surfaceColor),
                    label: AppText.spaceMono(
                      'ADD PRODUCT',
                      color: surfaceColor,
                      fontWeight: FontWeight.bold,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Row(
              children: [
                _buildFilterChip('ALL', textColor, surfaceColor),
                const SizedBox(width: 16),
                _buildFilterChip('MENS', textColor, surfaceColor),
                const SizedBox(width: 16),
                _buildFilterChip('WOMENS', textColor, surfaceColor),
              ],
            ),
          ),

          Expanded(
            child: productsAsync.when(
              data: (state) {
                return _buildProductGrid(state.products, textColor, state.isLoadingMore);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: AppText.spaceMono('Error: $err', color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color textColor, Color surfaceColor) {
    final isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? textColor : Colors.transparent,
          border: Border.all(color: textColor, width: 2),
        ),
        child: AppText.spaceMono(
          label,
          color: isSelected ? surfaceColor : textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, Color textColor, bool isLoadingMore) {
    if (products.isEmpty && !isLoadingMore) {
      return Center(
        child: AppText.spaceMono(
          'NO PRODUCTS FOUND',
          color: textColor.withValues(alpha: 0.5),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              final filter = ProductFilter(
                gender: _selectedFilter == 'ALL' ? null : _selectedFilter.toLowerCase(),
              );
              ref.invalidate(paginatedProductsProvider(filter));
            },
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(32),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 0.65,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                return _ProductCard(product: products[index], textColor: textColor);
              },
            ),
          ),
        ),
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final Color textColor;

  const _ProductCard({required this.product, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppPaths.adminEditProduct(product.id)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: textColor, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: product.image != null
                    ? AppImage(imageUrl: product.image!, fit: BoxFit.cover)
                    : const Icon(Icons.image_not_supported),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.spaceMono(
                    product.name,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  AppText.spaceMono(
                    product.price,
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.1),
                      border: Border.all(color: textColor, width: 1),
                    ),
                    child: AppText.spaceMono(
                      product.tag ?? 'NO TAG',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
