import 'package:flutter/material.dart';
import '../../../../core/router/app_paths.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/app_text.dart';
import '../../../../core/widgets/checkout_step_indicator.dart';
import '../../../../core/widgets/brutalist_hover_widget.dart';
import '../../providers/checkout_provider.dart';
import '../../../cart/providers/cart_provider.dart';
import '../../../order/providers/order_provider.dart';
import '../widgets/payment_method_card.dart';
import '../widgets/order_summary_section.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../auth/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage>
    with SingleTickerProviderStateMixin {
  String? _selectedMethod;
  bool _isProcessing = false;
  String _processingStatus = 'PROCESSING PAYMENT';
  late AnimationController _pulseController;
  late Razorpay _razorpay;
  String? _currentOrderId;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      _isProcessing = true;
      _processingStatus = 'VERIFYING TRANSACTION...';
    });
    try {
      await ref
          .read(orderProvider.notifier)
          .verifyPayment(
            orderId: _currentOrderId!,
            razorpayPaymentId: response.paymentId!,
            razorpayOrderId: response.orderId!,
            razorpaySignature: response.signature!,
          );

      if (!mounted) return;
      ref.read(lastPlacedOrderIdProvider.notifier).set(_currentOrderId);
      ref.read(cartProvider.notifier).clearCart();
      ref.read(checkoutProvider.notifier).reset();
      context.go(AppPaths.orderSuccess);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Verification Failed: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _isProcessing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedMethod == null) return;

    setState(() {
      _isProcessing = true;
      _processingStatus = 'SECURING CONNECTION...';
    });

    final checkout = ref.read(checkoutProvider);
    final cartItemsAsync = ref.read(cartProvider);
    final cartItems = cartItemsAsync.value ?? [];
    final subtotal = ref.read(checkoutSubtotalProvider);
    final discount = ref.read(checkoutDiscountProvider);
    final gst = ref.read(checkoutGstProvider);
    final total = ref.read(checkoutTotalProvider);

    try {
      // Place order securely via backend
      final result = await ref
          .read(orderProvider.notifier)
          .placeOrder(
            cartItems: cartItems,
            address: checkout.selectedAddress!,
            delivery: checkout.selectedDelivery!,
            paymentMethod: _selectedMethod!,
            subtotal: subtotal,
            discount: discount,
            gst: gst,
            total: total,
          );

      final orderId = result['order_id']!;
      final rzpOrderId = result['razorpay_order_id'];
      _currentOrderId = orderId;

      if (_selectedMethod == 'Cash on Delivery') {
        if (!mounted) return;
        ref.read(lastPlacedOrderIdProvider.notifier).set(orderId);
        ref.read(cartProvider.notifier).clearCart();
        ref.read(checkoutProvider.notifier).reset();
        context.go(AppPaths.orderSuccess);
      } else {
        final user = ref.read(authProvider).value;
        final razorpayKeyId = dotenv.env['RAZORPAY_KEY'] ??
            const String.fromEnvironment('RAZORPAY_KEY', defaultValue: '');

        var options = {
          'key': razorpayKeyId,
          'amount': (total * 100).toInt(),
          'name': 'The Tourers',
          'order_id': rzpOrderId,
          'description': 'Order $orderId',
          'prefill': {
            'contact': checkout.selectedAddress?.phone ?? '',
            'email': user?.email ?? '',
          },
          'theme': {'color': '#000000'},
        };

        _razorpay.open(options);
        // Update text while Razorpay overlay is open
        if (mounted) {
          setState(() {
            _processingStatus = 'AWAITING PAYMENT GATEWAY...';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    if (_isProcessing) {
      return Scaffold(body: _buildProcessingView(textColor, surfaceColor));
    }

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
                  const Spacer(),
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: textColor.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),

            const CheckoutStepIndicator(currentStep: 3),

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
                          'PAYMENT METHOD',
                          fontSize: isDesktop ? 48 : 36,
                          height: 0.9,
                          letterSpacing: 1.5,
                          color: textColor,
                        ),
                        const SizedBox(height: 8),
                        AppText.spaceMono(
                          '/// SECURE TRANSACTION PROTOCOL',
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 32),

                        // Payment methods
                        PaymentMethodCard(
                          title: 'PAY ONLINE',
                          subtitle: 'Credit Card, UPI, Net Banking, Wallets',
                          icon: Icons.security,
                          isSelected: _selectedMethod == 'Pay Online',
                          isRecommended: true,
                          onTap: () =>
                              setState(() => _selectedMethod = 'Pay Online'),
                        ),
                        PaymentMethodCard(
                          title: 'CASH ON DELIVERY',
                          subtitle: 'Pay when you receive',
                          icon: Icons.payments_outlined,
                          isSelected: _selectedMethod == 'Cash on Delivery',
                          onTap: () => setState(
                            () => _selectedMethod = 'Cash on Delivery',
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Delivery info summary
                        if (checkout.selectedAddress != null)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: textColor.withValues(alpha: 0.12),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText.spaceMono(
                                  '/// SHIPPING TO:',
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: textColor.withValues(alpha: 0.4),
                                ),
                                const SizedBox(height: 8),
                                AppText.spaceMono(
                                  checkout.selectedAddress!.formattedAddress,
                                  fontSize: 11,
                                  color: textColor.withValues(alpha: 0.7),
                                  height: 1.5,
                                ),
                                if (checkout.selectedDelivery != null) ...[
                                  const SizedBox(height: 8),
                                  AppText.spaceMono(
                                    '${checkout.selectedDelivery!.title} — ${checkout.selectedDelivery!.estimatedDays}',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textColor.withValues(alpha: 0.5),
                                  ),
                                ],
                              ],
                            ),
                          ),

                        // Order Summary
                        OrderSummarySection(
                          subtotal: subtotal,
                          discount: discount,
                          deliveryCharge: deliveryCharge,
                          gst: gst,
                          total: total,
                          discountPercentage: checkout.discountPercentage,
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
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText.spaceMono(
                          'TOTAL PAYABLE',
                          fontSize: 11,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                        AppText.bebas(
                          '₹${total.toStringAsFixed(0)}',
                          fontSize: 24,
                          color: textColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BrutalistHoverWidget(
                      shadowColor: textColor.withValues(alpha: 0.2),
                      offset: const Offset(5, 5),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _selectedMethod != null
                              ? _processPayment
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.neonAccent,
                            foregroundColor: AppTheme.pureBlack,
                            disabledBackgroundColor: AppTheme.pureBlack
                                .withValues(alpha: 0.1),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                              side: const BorderSide(
                                color: AppTheme.pureBlack,
                                width: 2,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock, size: 16),
                              const SizedBox(width: 8),
                              AppText.bebas(
                                _selectedMethod == 'Cash on Delivery'
                                    ? 'PLACE ORDER ↗'
                                    : 'PAY NOW ↗',
                                fontSize: 18,
                                letterSpacing: 1.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingView(Color textColor, Color surfaceColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated processing indicator
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 0.9 + (_pulseController.value * 0.2),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: textColor.withValues(
                        alpha: 0.3 + _pulseController.value * 0.7,
                      ),
                      width: 3,
                    ),
                  ),
                  child: Icon(Icons.lock_clock, size: 36, color: textColor),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          AppText.bebas(
            _processingStatus,
            fontSize: 28,
            letterSpacing: 2,
            color: textColor,
          ),
          const SizedBox(height: 12),
          AppText.spaceMono(
            '/// SECURE TRANSACTION IN PROGRESS...',
            fontSize: 11,
            color: textColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: textColor.withValues(alpha: 0.1),
              color: textColor,
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Do not close this screen',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              color: Colors.redAccent.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
