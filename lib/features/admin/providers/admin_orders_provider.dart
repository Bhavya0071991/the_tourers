import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../order/models/order_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/supabase_client.dart';
import '../data/repositories/admin_orders_repository.dart';
import '../../notification/data/repositories/notification_repository.dart';

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AdminOrdersRepository(supabaseClient);
});

class AdminOrderFilter {
  final String? searchQuery;

  AdminOrderFilter({this.searchQuery});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminOrderFilter &&
          runtimeType == other.runtimeType &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode => searchQuery.hashCode;
}

class PaginatedAdminOrdersState {
  final List<OrderModel> orders;
  final bool hasMore;
  final bool isLoadingMore;

  PaginatedAdminOrdersState({
    this.orders = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  PaginatedAdminOrdersState copyWith({
    List<OrderModel>? orders,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedAdminOrdersState(
      orders: orders ?? this.orders,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PaginatedAdminOrdersNotifier
    extends AsyncNotifier<PaginatedAdminOrdersState> {
  static const int _limit = 10;
  int _offset = 0;

  final AdminOrderFilter filter;
  PaginatedAdminOrdersNotifier(this.filter);

  RealtimeChannel? _subscription;

  @override
  Future<PaginatedAdminOrdersState> build() async {
    ref.onDispose(() {
      _subscription?.unsubscribe();
    });

    final user = ref.watch(authProvider).value;
    if (user == null ||
        user.status != AuthStatus.authenticated ||
        (user.role != 'admin' && user.role != 'super_admin')) {
      _subscription?.unsubscribe();
      _subscription = null;
      return PaginatedAdminOrdersState(hasMore: false);
    }

    _offset = 0;
    _setupRealtime();
    final initialOrders = await _fetchOrders(_offset);

    return PaginatedAdminOrdersState(
      orders: initialOrders,
      hasMore: initialOrders.length == _limit,
    );
  }

  void _setupRealtime() {
    _subscription?.unsubscribe();
    _subscription = ref
        .read(adminOrdersRepositoryProvider)
        .setupRealtimeSubscription(() async {
          // When a realtime update happens, refresh the currently loaded list
          final currentOrdersLength = state.value?.orders.length ?? _limit;
          final fetchLimit = currentOrdersLength < _limit
              ? _limit
              : currentOrdersLength;

          try {
            final refreshedOrders = await ref
                .read(adminOrdersRepositoryProvider)
                .fetchOrders(
                  limit: fetchLimit,
                  offset: 0,
                  searchQuery: filter.searchQuery,
                );
            if (state.value != null) {
              state = AsyncData(state.value!.copyWith(orders: refreshedOrders));
            }
          } catch (e) {
            if (kDebugMode) {
              print('Error refreshing orders on realtime update: $e');
            }
          }
        });
  }

  Future<List<OrderModel>> _fetchOrders(int offset) async {
    try {
      return await ref
          .read(adminOrdersRepositoryProvider)
          .fetchOrders(
            limit: _limit,
            offset: offset,
            searchQuery: filter.searchQuery,
          );
    } catch (e) {
      print('Error fetching paginated admin orders: $e');
      return [];
    }
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    try {
      _offset += _limit;
      final newOrders = await _fetchOrders(_offset);

      state = AsyncData(
        currentState.copyWith(
          orders: [...currentState.orders, ...newOrders],
          isLoadingMore: false,
          hasMore: newOrders.length == _limit,
        ),
      );
    } catch (e) {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }
}

final adminOrdersProvider = AsyncNotifierProvider.autoDispose
    .family<
      PaginatedAdminOrdersNotifier,
      PaginatedAdminOrdersState,
      AdminOrderFilter
    >(PaginatedAdminOrdersNotifier.new);

class AdminOrderOperationsNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final statusString = newStatus.name;
      final res = await ref
          .read(adminOrdersRepositoryProvider)
          .updateOrderStatus(orderId, statusString);

      if (res.isEmpty) {
        throw Exception(
          'Update failed. Check RLS policies or if order exists.',
        );
      }

      final targetOrder = await ref
          .read(adminOrdersRepositoryProvider)
          .fetchOrderById(orderId);
      if (targetOrder != null) {
        try {
          await ref
              .read(notificationRepositoryProvider)
              .insertNotification(
                userId: targetOrder.userId,
                title: 'Order Status Updated',
                message:
                    'Your order #${orderId.substring(0, 8)} is now ${newStatus.name.toUpperCase()}.',
                type: 'status_update',
              );
        } catch (e) {
          if (kDebugMode) {
            print('Notification error: $e');
          }
        }
      }

      ref.invalidate(adminOrderByIdProvider(orderId));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating order status: $e');
      }
      throw Exception('Failed to update order status');
    }
  }
}

final adminOrderOperationsProvider =
    NotifierProvider<AdminOrderOperationsNotifier, void>(
      AdminOrderOperationsNotifier.new,
    );

final adminOrderByIdProvider = FutureProvider.autoDispose
    .family<OrderModel?, String>((ref, id) async {
      return await ref.read(adminOrdersRepositoryProvider).fetchOrderById(id);
    });
