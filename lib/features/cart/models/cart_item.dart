class CartItem {
  final String id;
  final Map<String, String> product;
  final String size;
  final String? customText;
  final int quantity;
  final String? frontDesignPreview;
  final String? backDesignPreview;
  final String? frontPrintUrl;
  final String? backPrintUrl;

  const CartItem({
    required this.id,
    required this.product,
    required this.size,
    this.customText,
    required this.quantity,
    this.frontDesignPreview,
    this.backDesignPreview,
    this.frontPrintUrl,
    this.backPrintUrl,
  });

  double get unitPrice {
    final priceStr = product['price'] ?? '₹0';
    // Remove symbols and commas, e.g. "₹2,499" -> 2499.0
    final numericStr = priceStr.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericStr) ?? 0.0;
  }

  double get totalPrice => unitPrice * quantity;

  CartItem copyWith({
    String? id,
    Map<String, String>? product,
    String? size,
    String? customText,
    int? quantity,
    String? frontDesignPreview,
    String? backDesignPreview,
    String? frontPrintUrl,
    String? backPrintUrl,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      size: size ?? this.size,
      customText: customText ?? this.customText,
      quantity: quantity ?? this.quantity,
      frontDesignPreview: frontDesignPreview ?? this.frontDesignPreview,
      backDesignPreview: backDesignPreview ?? this.backDesignPreview,
      frontPrintUrl: frontPrintUrl ?? this.frontPrintUrl,
      backPrintUrl: backPrintUrl ?? this.backPrintUrl,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      product: Map<String, String>.from(json['product_snapshot'] as Map? ?? {}),
      size: json['size'] as String? ?? 'OS',
      customText: json['custom_text'] as String?,
      quantity: json['quantity'] as int? ?? 1,
      frontDesignPreview: json['front_design_preview'] as String?,
      backDesignPreview: json['back_design_preview'] as String?,
      frontPrintUrl: json['front_print_url'] as String?,
      backPrintUrl: json['back_print_url'] as String?,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      'user_id': userId,
      'product_id': product['id'] ?? 'unknown',
      'product_snapshot': product,
      'size': size,
      'custom_text': customText,
      'quantity': quantity,
      'front_design_preview': frontDesignPreview,
      'back_design_preview': backDesignPreview,
      'front_print_url': frontPrintUrl,
      'back_print_url': backPrintUrl,
    };
  }
}
