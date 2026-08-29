import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../order/models/order_model.dart';

class AdminOrdersRepository {
  final SupabaseClient _supabaseClient;

  AdminOrdersRepository(this._supabaseClient);

  Future<List<OrderModel>> fetchOrders({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
  }) async {
    var query = _supabaseClient
        .from('orders')
        .select('''
          *,
          order_items(*),
          user_addresses(*),
          delivery_methods(*)
        ''')
        .or(
          'payment_status.eq.paid,payment_status.eq.refunded,payment_method.eq.Cash on Delivery',
        );

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('id', '%$searchQuery%');
    }

    final response = await query
        .order('ordered_at', ascending: false)
        .range(offset, offset + limit - 1);

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
      final productsResponse = await _supabaseClient
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
  }

  Future<List<Map<String, dynamic>>> updateOrderStatus(
    String orderId,
    String statusString,
  ) async {
    return await _supabaseClient
        .from('orders')
        .update({'status': statusString})
        .eq('id', orderId)
        .select();
  }

  RealtimeChannel setupRealtimeSubscription(Future<void> Function() onUpdate) {
    return _supabaseClient
        .channel('public:admin_orders')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload) async {
            await onUpdate();
          },
        )
        .subscribe();
  }

  Future<OrderModel?> fetchOrderById(String orderId) async {
    try {
      final orders = await fetchOrders(
        limit: 10,
        offset: 0,
        searchQuery: orderId,
      );
      final exactMatch = orders.where((o) => o.id == orderId).toList();
      if (exactMatch.isNotEmpty) {
        return exactMatch.first;
      }
      return null;
    } catch (e) {
      print('Error fetching order by ID: $e');
      return null;
    }
  }
}
