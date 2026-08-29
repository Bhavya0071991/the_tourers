import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/constants/app_strings.dart';
import '../../models/customer_model.dart';
import '../../../order/providers/order_provider.dart';
import '../widgets/admin_info_card.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';

class AdminCustomerDetailsPage extends ConsumerWidget {
  final String customerId;

  const AdminCustomerDetailsPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find customer by ID
    final customer = mockCustomers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => mockCustomers.first, // fallback for demo
    );

    // Get all orders and filter by this customer (mock logic based on name for now)
    final allOrders = ref.watch(orderProvider).value ?? [];
    final customerOrders = allOrders
        .where((order) => order.shippingAddress.fullName == customer.name)
        .toList();

    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: AppText.spaceMono('${AppStrings.adminColCustomer} ${customer.id}', fontSize: 16),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppPaths.adminCustomers),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            AppText.bebas(
              customer.name.toUpperCase(),
              fontSize: 32,
              letterSpacing: 2.0,
              color: textColor,
            ),
            const SizedBox(height: 8),
            AppText.spaceMono(
              '${AppStrings.adminCustomerJoined} ${DateFormat('dd MMM yyyy').format(customer.joinedAt)}',
              fontSize: 12,
              color: textColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: AdminInfoCard(
                    title: AppStrings.adminContactInfo,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.spaceMono(customer.email, fontSize: 14),
                        const SizedBox(height: 8),
                        AppText.spaceMono(customer.phone, fontSize: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: AdminInfoCard(
                    title: AppStrings.adminLifetimeValue,
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.spaceMono(
                          '₹${customer.totalSpent.toStringAsFixed(0)}',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        const SizedBox(height: 4),
                        AppText.spaceMono(
                          AppStrings.adminAcrossOrders.replaceAll('%s', customer.totalOrders.toString()),
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Order History
            AppText.bebas(
              AppStrings.adminOrderHistory,
              fontSize: 24,
              letterSpacing: 1.5,
              color: textColor,
            ),
            const SizedBox(height: 16),
            
            if (customerOrders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                ),
                child: Center(
                  child: AppText.spaceMono(
                    AppStrings.adminNoOrdersFound,
                    fontSize: 14,
                    color: textColor.withValues(alpha: 0.5),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: textColor, width: 2),
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: textColor,
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: AppText.spaceMono(AppStrings.adminColOrderId, color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
                          Expanded(flex: 2, child: AppText.spaceMono(AppStrings.adminColDate, color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
                          Expanded(flex: 1, child: AppText.spaceMono(AppStrings.adminColItems, color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
                          Expanded(flex: 2, child: AppText.spaceMono(AppStrings.adminColStatus, color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
                          Expanded(flex: 2, child: AppText.spaceMono(AppStrings.adminColTotal, color: Theme.of(context).colorScheme.surface, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // Rows
                    ...customerOrders.map((order) {
                      return BrutalistHoverWidget(
                        child: InkWell(
                          onTap: () => context.go(AppPaths.adminOrderDetails(order.id)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              border: Border(top: BorderSide(color: textColor, width: 2)),
                            ),
                            child: Row(
                              children: [
                                Expanded(flex: 2, child: AppText.spaceMono(order.id, color: textColor)),
                                Expanded(flex: 2, child: AppText.spaceMono(DateFormat('dd MMM yyyy').format(order.orderedAt), color: textColor)),
                                Expanded(flex: 1, child: AppText.spaceMono(order.totalItemCount.toString(), color: textColor)),
                                Expanded(
                                  flex: 2, 
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: textColor, width: 1),
                                      ),
                                      child: AppText.spaceMono(order.statusLabel, color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ),
                                Expanded(flex: 2, child: AppText.spaceMono('₹${order.total.toStringAsFixed(0)}', color: textColor)),
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
        ),
      ),
    );
  }
}
