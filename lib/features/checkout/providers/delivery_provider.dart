import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery_method.dart';
import '../../../core/network/supabase_client.dart';

final deliveryMethodsProvider = FutureProvider<List<DeliveryMethod>>((
  ref,
) async {
  try {
    final response = await ref
        .read(supabaseClientProvider)
        .from('delivery_methods')
        .select()
        .order('charge', ascending: true);

    return (response as List)
        .map((json) => DeliveryMethod.fromJson(json))
        .toList();
  } catch (e) {
    // Fallback to defaults if table doesn't exist or network fails
    return DeliveryMethod.getAll();
  }
});

class SelectedDeliveryNotifier extends Notifier<DeliveryMethod?> {
  @override
  DeliveryMethod? build() {
    final methodsAsync = ref.watch(deliveryMethodsProvider);
    final methods = methodsAsync.value ?? [];
    return methods.isNotEmpty ? methods.first : null;
  }

  void select(DeliveryMethod? method) {
    state = method;
  }
}

final selectedDeliveryProvider =
    NotifierProvider<SelectedDeliveryNotifier, DeliveryMethod?>(
      SelectedDeliveryNotifier.new,
    );
