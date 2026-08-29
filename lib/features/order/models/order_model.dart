import '../../checkout/models/address_model.dart';
import '../../checkout/models/delivery_method.dart';
import '../../cart/models/cart_item.dart';

enum OrderStatus { processing, shipped, outForDelivery, delivered, cancelled }

enum PaymentStatus { paid, pending, failed, refunded }

class TrackingEvent {
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isCompleted;

  const TrackingEvent({
    required this.title,
    required this.description,
    required this.timestamp,
    this.isCompleted = false,
  });
}

class OrderItem {
  final String? productId;
  final String name;
  final String size;
  final String? imageUrl;
  final List<String> images;
  final String? customText;
  final String? frontDesignPreview;
  final String? backDesignPreview;
  final String? frontPrintUrl;
  final String? backPrintUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? tag;

  const OrderItem({
    this.productId,
    required this.name,
    required this.size,
    this.imageUrl,
    this.images = const [],
    this.customText,
    this.frontDesignPreview,
    this.backDesignPreview,
    this.frontPrintUrl,
    this.backPrintUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.tag,
  });

  factory OrderItem.fromCartItem(CartItem cartItem) {
    return OrderItem(
      productId: cartItem.product['id'],
      name: cartItem.product['name'] ?? '',
      size: cartItem.size,
      imageUrl: cartItem.product['image'],
      images:
          cartItem.product['images'] != null &&
              cartItem.product['images']!.isNotEmpty
          ? cartItem.product['images']!.split('||')
          : [],
      customText: cartItem.customText,
      frontDesignPreview: cartItem.frontDesignPreview,
      backDesignPreview: cartItem.backDesignPreview,
      frontPrintUrl: cartItem.frontPrintUrl,
      backPrintUrl: cartItem.backPrintUrl,
      quantity: cartItem.quantity,
      unitPrice: cartItem.unitPrice,
      totalPrice: cartItem.totalPrice,
      tag: cartItem.product['tag'],
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['products'] != null && json['products']['images'] != null) {
      parsedImages = List<String>.from(json['products']['images']);
    }

    return OrderItem(
      productId: json['product_id'] as String?,
      name: json['product_name'] as String,
      size: json['size'] as String,
      imageUrl: json['products'] != null
          ? json['products']['image'] as String?
          : null,
      images: parsedImages,
      customText: json['custom_text'] as String?,
      frontDesignPreview: json['front_design_preview'] as String?,
      backDesignPreview: json['back_design_preview'] as String?,
      frontPrintUrl: json['front_print_url'] as String?,
      backPrintUrl: json['back_print_url'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      tag: json['tag'] as String?,
    );
  }
}

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final Address shippingAddress;
  final DeliveryMethod deliveryMethod;
  final String paymentMethod;
  final PaymentStatus paymentStatus;
  final OrderStatus status;
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double gst;
  final double total;
  final DateTime orderedAt;
  final DateTime? estimatedDelivery;
  final List<TrackingEvent> timeline;
  final String? printfulOrderId;
  final String? printfulSyncStatus;
  final String? trackingUrl;
  final String userId;

  const OrderModel({
    required this.id,
    required this.items,
    required this.shippingAddress,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.gst,
    required this.total,
    required this.orderedAt,
    this.estimatedDelivery,
    this.timeline = const [],
    this.printfulOrderId,
    this.printfulSyncStatus,
    this.trackingUrl,
    required this.userId,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  OrderModel copyWith({OrderStatus? status}) {
    return OrderModel(
      id: id,
      items: items,
      shippingAddress: shippingAddress,
      deliveryMethod: deliveryMethod,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus,
      status: status ?? this.status,
      subtotal: subtotal,
      discount: discount,
      deliveryCharge: deliveryCharge,
      gst: gst,
      total: total,
      orderedAt: orderedAt,
      estimatedDelivery: estimatedDelivery,
      timeline: timeline,
      printfulOrderId: printfulOrderId,
      printfulSyncStatus: printfulSyncStatus,
      trackingUrl: trackingUrl,
      userId: userId,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.processing:
        return 'PROCESSING';
      case OrderStatus.shipped:
        return 'SHIPPED';
      case OrderStatus.outForDelivery:
        return 'OUT FOR DELIVERY';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  String get paymentStatusLabel {
    switch (paymentStatus) {
      case PaymentStatus.paid:
        return 'PAID';
      case PaymentStatus.pending:
        return 'PENDING';
      case PaymentStatus.failed:
        return 'FAILED';
      case PaymentStatus.refunded:
        return 'REFUNDED';
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Parse order status
    OrderStatus parsedStatus = OrderStatus.processing;
    switch (json['status']) {
      case 'shipped':
        parsedStatus = OrderStatus.shipped;
        break;
      case 'delivered':
        parsedStatus = OrderStatus.delivered;
        break;
      case 'cancelled':
        parsedStatus = OrderStatus.cancelled;
        break;
      default:
        parsedStatus = OrderStatus.processing;
    }

    // Parse payment status
    PaymentStatus parsedPaymentStatus = PaymentStatus.pending;
    switch (json['payment_status']) {
      case 'paid':
        parsedPaymentStatus = PaymentStatus.paid;
        break;
      case 'failed':
        parsedPaymentStatus = PaymentStatus.failed;
        break;
      case 'refunded':
        parsedPaymentStatus = PaymentStatus.refunded;
        break;
      default:
        parsedPaymentStatus = PaymentStatus.pending;
    }

    // Parse items
    final itemsList =
        (json['order_items'] as List<dynamic>?)
            ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse address and delivery method
    Address? address;
    if (json['user_addresses'] != null) {
      address = Address.fromJson(
        json['user_addresses'] as Map<String, dynamic>,
      );
    }

    DeliveryMethod? deliveryMethod;
    if (json['delivery_methods'] != null) {
      deliveryMethod = DeliveryMethod.fromJson(
        json['delivery_methods'] as Map<String, dynamic>,
      );
    }

    return OrderModel(
      id: json['id'] as String,
      items: itemsList,
      shippingAddress:
          address ??
          const Address(
            id: '',
            fullName: 'Unknown',
            phone: '',
            addressLine: '',
            city: '',
            state: '',
            pincode: '',
          ),
      deliveryMethod:
          deliveryMethod ??
          const DeliveryMethod(
            type: DeliveryType.standard,
            title: 'Unknown',
            description: '',
            charge: 0,
            estimatedDays: '',
          ),
      paymentMethod: json['payment_method'] as String,
      paymentStatus: parsedPaymentStatus,
      status: parsedStatus,
      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      deliveryCharge: (json['delivery_charge'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      orderedAt: DateTime.parse(json['ordered_at'] as String),
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'] as String)
          : null,
      timeline: const [], // Could be parsed if stored in DB
      printfulOrderId: json['printful_order_id'] as String?,
      printfulSyncStatus: json['printful_sync_status'] as String?,
      trackingUrl: json['tracking_url'] as String?,
      userId: json['user_id'] as String? ?? '',
    );
  }
}
