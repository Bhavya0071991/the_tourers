import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/admin_orders_provider.dart';
import '../../../order/models/order_model.dart';
import '../../../product/providers/product_provider.dart';
import '../../../../core/widgets/app_image.dart';
import '../widgets/admin_metric_card.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersState = ref.watch(adminOrdersProvider(AdminOrderFilter())).value;
    final orders = ordersState?.orders ?? [];
    final productsState = ref.watch(paginatedProductsProvider(const ProductFilter())).value;
    final products = productsState?.products ?? [];
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    // Calculate accurate revenue: only completed payments or COD, and not cancelled
    final validOrdersForRevenue = orders.where(
      (o) =>
          o.status != OrderStatus.cancelled &&
          (o.paymentStatus == PaymentStatus.paid ||
              o.paymentMethod == 'Cash on Delivery'),
    );
    final totalRevenue = validOrdersForRevenue.fold<double>(
      0,
      (sum, o) => sum + o.total,
    );

    final totalOrders = orders.length;
    final ongoingOrders = orders
        .where(
          (o) =>
              o.status != OrderStatus.delivered &&
              o.status != OrderStatus.cancelled,
        )
        .length;
    final totalProducts = products.length;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminOrdersProvider);
        ref.invalidate(paginatedProductsProvider(const ProductFilter()));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bebas(
              AppStrings.adminNavDashboard,
              fontSize: 32,
              letterSpacing: 2.0,
              color: textColor,
            ),
            const SizedBox(height: 32),

            // Metrics Row
            Row(
              children: [
                Expanded(
                  child: AdminMetricCard(
                    title: AppStrings.adminTotalRevenue,
                    value: '₹${NumberFormat('#,##0').format(totalRevenue)}',
                    icon: Icons.currency_rupee,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AdminMetricCard(
                    title: AppStrings.adminTotalOrders,
                    value: totalOrders.toString(),
                    icon: Icons.shopping_bag_outlined,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AdminMetricCard(
                    title: AppStrings.adminOngoingOrders,
                    value: ongoingOrders.toString(),
                    icon: Icons.local_shipping_outlined,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AdminMetricCard(
                    title: 'TOTAL PRODUCTS',
                    value: totalProducts.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Responsive Tables Layout
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildRecentOrdersTable(
                          context,
                          orders,
                          textColor,
                          surfaceColor,
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 4,
                        child: _buildRecentProductsTable(
                          context,
                          products,
                          textColor,
                          surfaceColor,
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecentOrdersTable(
                        context,
                        orders,
                        textColor,
                        surfaceColor,
                      ),
                      const SizedBox(height: 48),
                      _buildRecentProductsTable(
                        context,
                        products,
                        textColor,
                        surfaceColor,
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersTable(
    BuildContext context,
    List<OrderModel> orders,
    Color textColor,
    Color surfaceColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.bebas(
              AppStrings.adminRecentOrders,
              fontSize: 24,
              letterSpacing: 1.5,
              color: textColor,
            ),
            TextButton(
              onPressed: () => context.go(AppPaths.adminOrders),
              child: const Text(AppStrings.adminViewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: textColor, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(color: textColor),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: AppText.spaceMono(
                        AppStrings.adminColOrderId,
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppText.spaceMono(
                        AppStrings.adminColDate,
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: AppText.spaceMono(
                        AppStrings.adminColCustomer,
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: AppText.spaceMono(
                        AppStrings.adminColItems,
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppText.spaceMono(
                        AppStrings.adminColStatus,
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppText.spaceMono(
                        AppStrings.adminColTotal,
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              if (orders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: AppText.spaceMono(
                    'No orders yet',
                    color: textColor.withValues(alpha: 0.5),
                  ),
                )
              else
                ...orders.take(5).map((order) {
                  return BrutalistHoverWidget(
                    child: InkWell(
                      onTap: () =>
                          context.go(AppPaths.adminOrderDetails(order.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border(
                            top: BorderSide(color: textColor, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: AppText.spaceMono(
                                order.id,
                                color: textColor,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppText.spaceMono(
                                DateFormat(
                                  'dd MMM yyyy',
                                ).format(order.orderedAt),
                                color: textColor,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: AppText.spaceMono(
                                order.shippingAddress.fullName,
                                color: textColor,
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  if (order.items.isNotEmpty &&
                                      (order.items.first.imageUrl != null || order.items.first.frontDesignPreview != null))
                                    Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: textColor.withValues(
                                            alpha: 0.2,
                                          ),
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (order.items.first.frontDesignPreview != null &&
                                              order.items.first.frontDesignPreview!.startsWith('http'))
                                            Positioned.fill(
                                              child: AppImage(
                                                imageUrl: order.items.first.frontDesignPreview!,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          else if (order.items.first.imageUrl != null)
                                            Positioned.fill(
                                              child: order.items.first.imageUrl!.startsWith('assets/')
                                                  ? Image.asset(
                                                      order.items.first.imageUrl!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : AppImage(
                                                      imageUrl: order.items.first.imageUrl!,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          if (order.items.first.frontDesignPreview != null &&
                                              !order.items.first.frontDesignPreview!.startsWith('http'))
                                            Positioned.fill(
                                              child: Image.memory(
                                                base64Decode(order.items.first.frontDesignPreview!),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  AppText.spaceMono(
                                    '${order.totalItemCount}',
                                    color: textColor,
                                    fontSize: 10,
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppText.spaceMono(
                                order.statusLabel,
                                color: textColor,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppText.spaceMono(
                                '₹${order.total.toStringAsFixed(0)}',
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentProductsTable(
    BuildContext context,
    List<dynamic> products,
    Color textColor,
    Color surfaceColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText.bebas(
              'RECENTLY ADDED PRODUCTS',
              fontSize: 24,
              letterSpacing: 1.5,
              color: textColor,
            ),
            TextButton(
              onPressed: () => context.go(AppPaths.adminProducts),
              child: const Text(AppStrings.adminViewAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: textColor, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(color: textColor),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppText.spaceMono(
                        'IMG',
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: AppText.spaceMono(
                        'NAME',
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppText.spaceMono(
                        'PRICE',
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: AppText.spaceMono(
                        'TAG',
                        color: surfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Rows
              if (products.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: AppText.spaceMono(
                    'No products found',
                    color: textColor.withValues(alpha: 0.5),
                  ),
                )
              else
                ...products.take(5).map((product) {
                  return BrutalistHoverWidget(
                    child: InkWell(
                      onTap: () =>
                          context.go(AppPaths.adminEditProduct(product.id)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          border: Border(
                            top: BorderSide(color: textColor, width: 2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: textColor,
                                    width: 1,
                                  ),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                ),
                                child: product.image != null
                                    ? AppImage(
                                        imageUrl: product.image!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.image_not_supported,
                                        size: 20,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: AppText.spaceMono(
                                product.name,
                                color: textColor,
                                maxLines: 1,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppText.spaceMono(
                                product.price,
                                color: textColor,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppText.spaceMono(
                                product.tag ?? '-',
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}
