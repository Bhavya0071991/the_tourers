import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/customer_model.dart';

class CustomerRepository {
  final SupabaseClient _supabaseClient;

  CustomerRepository(this._supabaseClient);

  Future<List<CustomerModel>> fetchCustomers() async {
    final response = await _supabaseClient.from('profiles').select('*');

    return response.map((json) {
      return CustomerModel(
        id: json['id'] as String? ?? '',
        name:
            json['full_name'] as String? ??
            json['username'] as String? ??
            'Unknown',
        email: json['email'] as String? ?? 'Unknown',
        phone: json['phone'] as String? ?? 'N/A',
        joinedAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        totalOrders: json['total_orders'] as int? ?? 0,
        totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0.0,
        role: json['role'] as String? ?? 'user',
      );
    }).toList();
  }

  Future<void> updateRole(String customerId, String newRole) async {
    await _supabaseClient
        .from('profiles')
        .update({'role': newRole})
        .eq('id', customerId);
  }
}
