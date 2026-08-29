import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../../checkout/providers/address_provider.dart';
import '../../../checkout/presentation/widgets/address_card.dart';
import '../../../checkout/presentation/widgets/address_form_sheet.dart';
import '../../../checkout/models/address_model.dart';

class SavedAddressesPage extends ConsumerWidget {
  const SavedAddressesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: textColor.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  AppText.bebas(
                    'SAVED ADDRESSES',
                    fontSize: 22,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ],
              ),
            ),

            Expanded(
              child: addressesAsync.when(
                data: (addresses) {
                  if (addresses.isEmpty) {
                    return _buildEmptyState(context, ref, textColor);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: addresses.length + 1,
                    itemBuilder: (context, index) {
                      if (index == addresses.length) {
                        return _buildAddButton(context, ref, textColor);
                      }
                      final address = addresses[index];
                      return AddressCard(
                        address: address,
                        isSelected: address.isDefault,
                        onTap: () {
                          ref.read(addressProvider.notifier).setDefault(address.id);
                        },
                        onEdit: () => _showForm(context, ref, address),
                        onDelete: () {
                          ref.read(addressProvider.notifier).removeAddress(address.id);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (err, stack) => Center(
                  child: Text(
                    'Error: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48,
              color: textColor.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            AppText.bebas(
              'NO SAVED ADDRESSES',
              fontSize: 24,
              color: textColor,
            ),
            const SizedBox(height: 24),
            BrutalistHoverWidget(
              shadowColor: textColor.withValues(alpha: 0.15),
              offset: const Offset(4, 4),
              child: ElevatedButton(
                onPressed: () => _showForm(context, ref, null),
                child: AppText.bebas(
                  'ADD ADDRESS ↗',
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GestureDetector(
        onTap: () => _showForm(context, ref, null),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: textColor.withValues(alpha: 0.2), width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: textColor.withValues(alpha: 0.4), size: 20),
              const SizedBox(width: 12),
              AppText.spaceMono(
                'ADD NEW ADDRESS',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, WidgetRef ref, Address? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(
        existingAddress: existing,
        onSave: (address) async {
          if (existing != null) {
            await ref.read(addressProvider.notifier).updateAddress(address);
          } else {
            await ref.read(addressProvider.notifier).addAddress(address);
          }
        },
      ),
    );
  }
}
