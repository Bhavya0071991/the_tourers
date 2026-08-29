import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../wishlist/providers/wishlist_provider.dart';
import '../../../product/presentation/widgets/product_card.dart';

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar (Same as MyOrdersPage)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: textColor.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppPaths.home);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  AppText.bebas(
                    'WISHLIST',
                    fontSize: 22,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ],
              ),
            ),

            // Dynamic content
            Expanded(
              child: wishlistAsync.when(
                data: (items) {
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 400),
                          padding: const EdgeInsets.all(32.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: textColor.withValues(alpha: 0.2),
                              width: 2.0,
                            ),
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: textColor.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Icon(
                                  Icons.favorite_border,
                                  size: 48,
                                  color: textColor.withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppText.bebas(
                                'NO SAVED ITEMS',
                                fontSize: 28,
                                letterSpacing: 2.0,
                                color: textColor,
                              ),
                              const SizedBox(height: 8),
                              AppText.spaceMono(
                                'Your wishlist is currently empty. Start exploring and save items you love.',
                                fontSize: 12,
                                color: textColor.withValues(alpha: 0.5),
                                textAlign: TextAlign.center,
                                height: 1.5,
                              ),
                              const SizedBox(height: 32),
                              InkWell(
                                onTap: () => context.go(AppPaths.home),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: textColor,
                                    border: Border.all(color: textColor),
                                  ),
                                  child: Center(
                                    child: AppText.spaceMono(
                                      'EXPLORE CATALOG',
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.surface,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;
                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 3;
                      } else if (constraints.maxWidth <= 550) {
                        crossAxisCount = 1;
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 32.0,
                        ),
                        itemCount: items.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 28,
                        ),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          if (item.product == null) {
                            return const SizedBox.shrink();
                          }

                          return ProductCard(product: item.product!);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text(
                    'Error loading wishlist: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
