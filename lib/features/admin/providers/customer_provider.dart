import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer_model.dart';
import '../../../core/network/supabase_client.dart';
import '../data/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return CustomerRepository(supabaseClient);
});

class CustomerNotifier extends AsyncNotifier<List<CustomerModel>> {
  @override
  Future<List<CustomerModel>> build() async {
    return _fetchCustomers();
  }

  Future<List<CustomerModel>> _fetchCustomers() async {
    return await ref.read(customerRepositoryProvider).fetchCustomers();
  }

  Future<void> updateRole(String customerId, String newRole) async {
    final prev = state.value ?? [];

    // Optimistic update
    state = AsyncData(
      prev.map((c) {
        if (c.id == customerId) {
          return CustomerModel(
            id: c.id,
            name: c.name,
            email: c.email,
            phone: c.phone,
            joinedAt: c.joinedAt,
            totalOrders: c.totalOrders,
            totalSpent: c.totalSpent,
            role: newRole,
          );
        }
        return c;
      }).toList(),
    );

    try {
      await ref.read(customerRepositoryProvider).updateRole(customerId, newRole);
    } catch (e) {
      // Revert on failure
      state = AsyncData(prev);
      rethrow;
    }
  }
}

final customerProvider =
    AsyncNotifierProvider<CustomerNotifier, List<CustomerModel>>(
      CustomerNotifier.new,
    );
