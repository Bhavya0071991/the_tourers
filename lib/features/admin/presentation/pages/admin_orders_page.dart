import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../providers/admin_orders_provider.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/app_field.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  String _searchQuery = '';
  Timer? _debounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final filter = AdminOrderFilter(searchQuery: _searchQuery);
      ref.read(adminOrdersProvider(filter).notifier).loadMore();
    }
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = val.trim();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filter = AdminOrderFilter(searchQuery: _searchQuery);
    final ordersState = ref.watch(adminOrdersProvider(filter));
    final orders = ordersState.value?.orders ?? [];
    final isLoadingMore = ordersState.value?.isLoadingMore ?? false;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(adminOrdersProvider(filter));
      },
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.bebas(
              AppStrings.adminOrdersManagement,
              fontSize: 32,
              letterSpacing: 2.0,
              color: textColor,
            ),
            const SizedBox(height: 32),

            // Search Field
            AppField(
              hintText: 'SEARCH ORDERS BY ID',
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 24),

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
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: AppText.spaceMono(
                            AppStrings.adminColDate,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: AppText.spaceMono(
                            AppStrings.adminColCustomer,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: AppText.spaceMono(
                            AppStrings.adminColItems,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: AppText.spaceMono(
                            AppStrings.adminColStatus,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: AppText.spaceMono(
                            AppStrings.adminColTotal,
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Rows
                  if (orders.isEmpty && ordersState.isLoading)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(color: textColor),
                      ),
                    )
                  else if (orders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: AppText.spaceMono(
                          'No orders found matching "$_searchQuery"',
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ),
                    )
                  else
                    ...orders.map((order) {
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
                              color: Theme.of(context).colorScheme.surface,
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
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      if (order.items.isNotEmpty &&
                                          (order.items.first.imageUrl != null || order.items.first.frontDesignPreview != null))
                                        Container(
                                          width: 32,
                                          height: 32,
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
                                        '${order.totalItemCount} items',
                                        color: textColor,
                                        fontSize: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: textColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: AppText.spaceMono(
                                        order.statusLabel,
                                        color: textColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                    
                  if (isLoadingMore)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: CircularProgressIndicator(color: textColor),
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
