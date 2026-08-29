import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_text.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../widgets/order_card.dart';

class MyOrdersPage extends ConsumerWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // App bar
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: textColor.withValues(alpha: 0.1)),
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
                      'MY ORDERS',
                      fontSize: 22,
                      letterSpacing: 1.5,
                      color: textColor,
                    ),
                  ],
                ),
              ),

              // Tab bar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: textColor.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: TabBar(
                  labelStyle: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: GoogleFonts.spaceMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  labelColor: textColor,
                  unselectedLabelColor: textColor.withValues(alpha: 0.4),
                  indicatorColor: textColor,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(text: 'ONGOING'),
                    Tab(text: 'DELIVERED'),
                    Tab(text: 'CANCELLED'),
                  ],
                ),
              ),

              // Tab views
              Expanded(
                child: TabBarView(
                  children: [
                    _OrderList(
                      ordersProvider: ongoingOrdersProvider,
                      emptyMessage: 'NO ACTIVE ORDERS',
                      emptyIcon: Icons.local_shipping_outlined,
                    ),
                    _OrderList(
                      ordersProvider: deliveredOrdersProvider,
                      emptyMessage: 'NO DELIVERED ORDERS',
                      emptyIcon: Icons.check_circle_outline,
                    ),
                    _OrderList(
                      ordersProvider: cancelledOrdersProvider,
                      emptyMessage: 'NO CANCELLED ORDERS',
                      emptyIcon: Icons.cancel_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderList extends ConsumerWidget {
  final Provider<List<OrderModel>> ordersProvider;
  final String emptyMessage;
  final IconData emptyIcon;

  const _OrderList({
    required this.ordersProvider,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 48,
              color: textColor.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 16),
            AppText.bebas(
              emptyMessage,
              fontSize: 22,
              color: textColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            AppText.spaceMono(
              '/// System found no records',
              fontSize: 10,
              color: textColor.withValues(alpha: 0.2),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderCard(
          order: order,
          onTap: () => context.push(AppPaths.orderDetails(order.id)),
        );
      },
    );
  }
}
