import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/checkout_step_indicator.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../providers/address_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../models/address_model.dart';
import '../widgets/address_card.dart';
import '../widgets/address_form_sheet.dart';

class AddressPage extends ConsumerWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(addressProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
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
                    'SECURE CHECKOUT',
                    fontSize: 22,
                    letterSpacing: 1.5,
                    color: textColor,
                  ),
                ],
              ),
            ),

            // Step indicator
            const CheckoutStepIndicator(currentStep: 1),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 64 : 24,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.bebas(
                          'DELIVERY ADDRESS',
                          fontSize: isDesktop ? 48 : 36,
                          height: 0.9,
                          letterSpacing: 1.5,
                          color: textColor,
                        ),
                        const SizedBox(height: 8),
                        AppText.spaceMono(
                          '/// SELECT OR ADD YOUR SHIPPING COORDINATES',
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 32),

                        // Address list
                        addressesAsync.when(
                          data: (addresses) {
                            if (addresses.isEmpty) {
                              return _buildEmptyState(context, ref, textColor, surfaceColor);
                            }
                            return Column(
                              children: [
                                ...addresses.map((address) {
                                  return AddressCard(
                                    address: address,
                                    isSelected: selectedAddress?.id == address.id,
                                    onTap: () {
                                      ref.read(selectedAddressProvider.notifier).select(address);
                                      ref.read(checkoutProvider.notifier).setAddress(address);
                                    },
                                    onEdit: () => _showAddressForm(context, ref, address),
                                    onDelete: () {
                                      ref.read(addressProvider.notifier).removeAddress(address.id);
                                    },
                                  );
                                }),
                              ],
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(48.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          error: (err, stack) => Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Error loading addresses: $err',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Add new address button
                        BrutalistHoverWidget(
                          shadowColor: textColor.withValues(alpha: 0.1),
                          offset: const Offset(4, 4),
                          child: GestureDetector(
                            onTap: () => _showAddressForm(context, ref, null),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: textColor.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: textColor.withValues(alpha: 0.5),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  AppText.spaceMono(
                                    'ADD NEW ADDRESS',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom CTA
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  top: BorderSide(color: textColor, width: 2),
                ),
              ),
              child: SafeArea(
                top: false,
                child: BrutalistHoverWidget(
                  shadowColor: textColor.withValues(alpha: 0.2),
                  offset: const Offset(5, 5),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedAddress != null
                          ? () {
                              ref.read(checkoutProvider.notifier).setAddress(selectedAddress);
                              context.push(AppPaths.checkoutDelivery);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: surfaceColor,
                        disabledBackgroundColor: textColor.withValues(alpha: 0.2),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: AppText.bebas(
                        'CONTINUE TO DELIVERY ↗',
                        fontSize: 18,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    WidgetRef ref,
    Color textColor,
    Color surfaceColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: textColor.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 48,
            color: textColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          AppText.bebas(
            'NO ADDRESSES SAVED',
            fontSize: 22,
            color: textColor,
          ),
          const SizedBox(height: 8),
          AppText.spaceMono(
            'Add a delivery address to continue',
            fontSize: 11,
            color: textColor.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  void _showAddressForm(
    BuildContext context,
    WidgetRef ref,
    Address? existing,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(
        existingAddress: existing,
        onSave: (address) async {
          if (existing != null) {
            await ref.read(addressProvider.notifier).updateAddress(address);
            ref.read(selectedAddressProvider.notifier).select(address);
          } else {
            final newAddress = await ref.read(addressProvider.notifier).addAddress(address);
            ref.read(selectedAddressProvider.notifier).select(newAddress);
          }
        },
      ),
    );
  }
}
