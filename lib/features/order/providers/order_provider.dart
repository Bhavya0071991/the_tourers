import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../../checkout/models/address_model.dart';
import '../../checkout/models/delivery_method.dart';
import '../../cart/models/cart_item.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/supabase_client.dart';
import '../../notification/data/repositories/notification_repository.dart';

class OrderNotifier extends AsyncNotifier<List<OrderModel>> {
  RealtimeChannel? _subscription;

  @override
  Future<List<OrderModel>> build() async {
    ref.onDispose(() {
      _subscription?.unsubscribe();
    });

    final user = ref.watch(authProvider).value;

    if (user == null ||
        user.status != AuthStatus.authenticated ||
        user.id == null) {
      _subscription?.unsubscribe();
      _subscription = null;
      return [];
    }

    _setupRealtime(user.id!);
    return _fetchOrders(user.id!);
  }

  void _setupRealtime(String userId) {
    _subscription?.unsubscribe();
    _subscription = ref.read(supabaseClientProvider)
        .channel('public:orders:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) async {
            // Trigger a refetch to get the updated status and relations
            final newOrders = await _fetchOrders(userId);
            state = AsyncData(newOrders);
          },
        )
        .subscribe();
  }

  Future<List<OrderModel>> _fetchOrders(String userId) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase
          .from('orders')
          .select('''
            *,
            order_items(*),
            user_addresses(*),
            delivery_methods(*)
          ''')
          .eq('user_id', userId)
          .or(
            'payment_status.eq.paid,payment_status.eq.refunded,payment_method.eq.Cash on Delivery',
          )
          .order('ordered_at', ascending: false);

      List<dynamic> rawOrders = response as List<dynamic>;

      // Collect all normal product IDs
      final Set<String> productIds = {};
      for (var order in rawOrders) {
        final items = order['order_items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final pid = item['product_id'] as String?;
          if (pid != null && !pid.startsWith('ai_custom_')) {
            productIds.add(pid);
          }
        }
      }

      // Fetch product images
      final Map<String, dynamic> productMap = {};
      if (productIds.isNotEmpty) {
        final productsResponse = await supabase
            .from('products')
            .select('id, image, images')
            .inFilter('id', productIds.toList());
        for (var p in productsResponse) {
          productMap[p['id']] = p;
        }
      }

      // Inject product images into order items
      for (var order in rawOrders) {
        final items = order['order_items'] as List<dynamic>? ?? [];
        for (var item in items) {
          final pid = item['product_id'] as String?;
          if (pid != null && productMap.containsKey(pid)) {
            item['products'] = productMap[pid];
          }
        }
      }

      final List<OrderModel> parsedOrders = rawOrders
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return parsedOrders;
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  Future<Map<String, String?>> placeOrder({
    required List<CartItem> cartItems,
    required Address address,
    required DeliveryMethod delivery,
    required String paymentMethod,
    required double subtotal,
    required double discount,
    required double gst,
    required double total,
  }) async {
    final user = ref.read(authProvider).value;
    if (user == null || user.status != AuthStatus.authenticated) {
      throw Exception('Must be logged in to place an order');
    }

    try {
      // Call the Supabase Edge Function to securely calculate price and place order
      final response = await ref.read(supabaseClientProvider).functions.invoke(
        'process_checkout',
        body: {
          'shipping_address_id': address.id,
          'delivery_method_id': delivery.id,
          'payment_method': paymentMethod,
        },
      );

      if (response.status == 200) {
        final data = response.data;
        if (data['success'] == true) {
          // Refresh orders
          state = AsyncData(await _fetchOrders(user.id!));
          
          try {
            await ref.read(notificationRepositoryProvider).insertNotification(
              userId: 'ADMIN',
              title: 'New Order Received',
              message: 'Order #${data['order_id']} was just placed.',
              type: 'order_created',
            );
          } catch (e) {
            print('Notification error: $e');
          }

          return {
            'order_id': data['order_id'],
            'razorpay_order_id': data['razorpay_order_id'],
          };
        } else {
          throw Exception(data['error'] ?? 'Unknown error during checkout');
        }
      } else {
        throw Exception('Failed to process checkout: ${response.status}');
      }
    } catch (e) {
      print('Edge function error: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> verifyPayment({
    required String orderId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      final response = await ref.read(supabaseClientProvider).functions.invoke(
        'verify_payment',
        body: {
          'order_id': orderId,
          'razorpay_payment_id': razorpayPaymentId,
          'razorpay_order_id': razorpayOrderId,
          'razorpay_signature': razorpaySignature,
        },
      );

      if (response.status == 200 && response.data['success'] == true) {
        final user = ref.read(authProvider).value;
        if (user != null && user.id != null) {
          // Refresh orders to get the updated 'paid' status
          state = AsyncData(await _fetchOrders(user.id!));
          
          try {
            await ref.read(notificationRepositoryProvider).insertNotification(
              userId: 'ADMIN',
              title: 'Payment Verified',
              message: 'Payment verified for Order #$orderId.',
              type: 'order_created',
            );
          } catch (e) {
            print('Notification error: $e');
          }
        }
      } else {
        throw Exception(
          response.data['error'] ?? 'Payment verification failed',
        );
      }
    } catch (e) {
      print('Payment verification error: $e');
      throw Exception('Payment verification failed');
    }
  }

  OrderModel? getOrderById(String id) {
    try {
      final orders = state.value ?? [];
      return orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      await ref.read(supabaseClientProvider)
          .from('orders')
          .update({'status': newStatus.name})
          .eq('id', orderId);

      // Optimistic update locally
      final currentOrders = state.value ?? [];
      state = AsyncData(
        currentOrders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(status: newStatus);
          }
          return order;
        }).toList(),
      );
    } catch (e) {
      print('Failed to update order status: $e');
    }
  }
}

final orderProvider = AsyncNotifierProvider<OrderNotifier, List<OrderModel>>(
  OrderNotifier.new,
);

// For UI compatibility, we will provide empty lists if not loaded yet
final ongoingOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderProvider).value ?? [];
  return orders
      .where(
        (o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled,
      )
      .toList();
});

final deliveredOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.delivered).toList();
});

final cancelledOrdersProvider = Provider<List<OrderModel>>((ref) {
  final orders = ref.watch(orderProvider).value ?? [];
  return orders.where((o) => o.status == OrderStatus.cancelled).toList();
});

class LastPlacedOrderIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? id) {
    state = id;
  }
}

final lastPlacedOrderIdProvider =
    NotifierProvider<LastPlacedOrderIdNotifier, String?>(
      LastPlacedOrderIdNotifier.new,
    );
