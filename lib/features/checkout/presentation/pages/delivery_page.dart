import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/checkout_step_indicator.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../providers/delivery_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../models/delivery_method.dart';
import '../widgets/delivery_option_card.dart';
import '../widgets/order_summary_section.dart';

class DeliveryPage extends ConsumerWidget {
  const DeliveryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveryMethodsAsync = ref.watch(deliveryMethodsProvider);
    final selectedDelivery = ref.watch(selectedDeliveryProvider);
    final subtotal = ref.watch(checkoutSubtotalProvider);
    final discount = ref.watch(checkoutDiscountProvider);
    final deliveryCharge = ref.watch(checkoutDeliveryChargeProvider);
    final gst = ref.watch(checkoutGstProvider);
    final total = ref.watch(checkoutTotalProvider);
    final checkout = ref.watch(checkoutProvider);
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

            const CheckoutStepIndicator(currentStep: 2),

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
                          'DELIVERY METHOD',
                          fontSize: isDesktop ? 48 : 36,
                          height: 0.9,
                          letterSpacing: 1.5,
                          color: textColor,
                        ),
                        const SizedBox(height: 8),
                        AppText.spaceMono(
                          '/// SELECT YOUR PREFERRED SHIPPING PROTOCOL',
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 32),

                        // Delivery to info
                        if (checkout.selectedAddress != null) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: surfaceColor,
                              border: Border.all(color: textColor, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: textColor.withValues(alpha: 0.1),
                                  offset: const Offset(6, 6),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.neonAccent,
                                    border: Border.all(
                                      color: textColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    size: 24,
                                    color: AppTheme.pureBlack,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AppText.spaceMono(
                                        '/// DESTINATION COORDINATES',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: textColor.withValues(alpha: 0.5),
                                      ),
                                      const SizedBox(height: 8),
                                      AppText.spaceMono(
                                        checkout.selectedAddress!.fullName
                                            .toUpperCase(),
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      const SizedBox(height: 4),
                                      AppText.spaceMono(
                                        checkout
                                            .selectedAddress!
                                            .formattedAddress,
                                        fontSize: 12,
                                        color: textColor.withValues(alpha: 0.8),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                InkWell(
                                  onTap: () => context.pop(),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: textColor,
                                      border: Border.all(
                                        color: textColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: AppText.spaceMono(
                                      'EDIT',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: surfaceColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Delivery options
                        deliveryMethodsAsync.when(
                          data: (methods) {
                            return Column(
                              children: methods
                                  .where(
                                    (m) =>
                                        m.isAvailable &&
                                        m.type == DeliveryType.standard,
                                  )
                                  .map((method) {
                                    return DeliveryOptionCard(
                                      method: method,
                                      isSelected:
                                          selectedDelivery?.type == method.type,
                                      onTap: () {
                                        ref
                                            .read(
                                              selectedDeliveryProvider.notifier,
                                            )
                                            .select(method);
                                        ref
                                            .read(checkoutProvider.notifier)
                                            .setDelivery(method);
                                      },
                                    );
                                  })
                                  .toList(),
                            );
                          },
                          loading: () => const Padding(
                            padding: EdgeInsets.all(48.0),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (err, stack) => Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'Error loading delivery methods: $err',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Order Summary
                        OrderSummarySection(
                          subtotal: subtotal,
                          discount: discount,
                          deliveryCharge: deliveryCharge,
                          gst: gst,
                          total: total,
                          discountPercentage: checkout.discountPercentage,
                          showGst: false,
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
                border: Border(top: BorderSide(color: textColor, width: 2)),
              ),
              child: SafeArea(
                top: false,
                child: BrutalistHoverWidget(
                  shadowColor: textColor.withValues(alpha: 0.2),
                  offset: const Offset(5, 5),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedDelivery != null
                          ? () {
                              ref
                                  .read(checkoutProvider.notifier)
                                  .setDelivery(selectedDelivery);
                              context.push(AppPaths.checkoutPayment);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: textColor,
                        foregroundColor: surfaceColor,
                        disabledBackgroundColor: textColor.withValues(
                          alpha: 0.2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      child: AppText.bebas(
                        'CONTINUE TO PAYMENT ↗',
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
}
