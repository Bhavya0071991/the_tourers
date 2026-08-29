import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';

import 'dart:async';
import '../../auth/providers/auth_provider.dart';
import '../../../core/network/supabase_client.dart';

class AddressNotifier extends AsyncNotifier<List<Address>> {
  @override
  FutureOr<List<Address>> build() async {
    return _fetchAddresses();
  }

  Future<List<Address>> _fetchAddresses() async {
    final user = ref.read(authProvider).value;
    if (user == null ||
        user.status != AuthStatus.authenticated ||
        user.id == null) {
      return [];
    }

    final response = await ref
        .read(supabaseClientProvider)
        .from('user_addresses')
        .select()
        .eq('user_id', user.id!)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Address.fromJson(json)).toList();
  }

  Future<Address> addAddress(Address address) async {
    final user = ref.read(authProvider).value;
    if (user == null ||
        user.status != AuthStatus.authenticated ||
        user.id == null) {
      throw Exception('Must be logged in to add an address');
    }

    try {
      if (address.isDefault) {
        // Unset previous defaults in Supabase
        await ref
            .read(supabaseClientProvider)
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', user.id!);
      }

      final response = await ref
          .read(supabaseClientProvider)
          .from('user_addresses')
          .insert(address.toJson(user.id!))
          .select()
          .single();

      final newAddress = Address.fromJson(response);
      state = AsyncData(await _fetchAddresses());
      return newAddress;
    } catch (e) {
      throw Exception('Failed to add address: $e');
    }
  }

  Future<void> updateAddress(Address updated) async {
    final user = ref.read(authProvider).value;
    if (user == null ||
        user.status != AuthStatus.authenticated ||
        user.id == null) {
      throw Exception('Must be logged in to update an address');
    }

    try {
      if (updated.isDefault) {
        // Unset previous defaults
        await ref
            .read(supabaseClientProvider)
            .from('user_addresses')
            .update({'is_default': false})
            .eq('user_id', user.id!);
      }

      await ref
          .read(supabaseClientProvider)
          .from('user_addresses')
          .update(updated.toJson(user.id!))
          .eq('id', updated.id)
          .eq('user_id', user.id!);

      state = AsyncData(await _fetchAddresses());
    } catch (e) {
      throw Exception('Failed to update address: $e');
    }
  }

  Future<void> removeAddress(String id) async {
    final user = ref.read(authProvider).value;
    if (user == null ||
        user.status != AuthStatus.authenticated ||
        user.id == null) {
      throw Exception('Must be logged in to delete an address');
    }

    try {
      await ref
          .read(supabaseClientProvider)
          .from('user_addresses')
          .delete()
          .eq('id', id)
          .eq('user_id', user.id!);

      state = AsyncData(await _fetchAddresses());
    } catch (e) {
      throw Exception('Failed to remove address: $e');
    }
  }

  Future<void> setDefault(String id) async {
    final user = ref.read(authProvider).value;
    if (user == null ||
        user.status != AuthStatus.authenticated ||
        user.id == null) {
      throw Exception('Must be logged in to update an address');
    }

    try {
      // First set all to false
      await ref
          .read(supabaseClientProvider)
          .from('user_addresses')
          .update({'is_default': false})
          .eq('user_id', user.id!);

      // Then set the selected one to true
      await ref
          .read(supabaseClientProvider)
          .from('user_addresses')
          .update({'is_default': true})
          .eq('id', id)
          .eq('user_id', user.id!);

      state = AsyncData(await _fetchAddresses());
    } catch (e) {
      throw Exception('Failed to set default address: $e');
    }
  }
}

final addressProvider = AsyncNotifierProvider<AddressNotifier, List<Address>>(
  AddressNotifier.new,
);

class SelectedAddressNotifier extends Notifier<Address?> {
  @override
  Address? build() {
    final addressesAsync = ref.watch(addressProvider);
    final addresses = addressesAsync.value ?? [];
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  void select(Address? address) {
    state = address;
  }
}

final selectedAddressProvider =
    NotifierProvider<SelectedAddressNotifier, Address?>(
      SelectedAddressNotifier.new,
    );

final defaultAddressProvider = Provider<Address?>((ref) {
  final addressesAsync = ref.watch(addressProvider);
  final addresses = addressesAsync.value ?? [];
  try {
    return addresses.firstWhere((a) => a.isDefault);
  } catch (_) {
    return addresses.isNotEmpty ? addresses.first : null;
  }
});
