enum DeliveryType { standard, express, sameDay }

class DeliveryMethod {
  final String? id;
  final DeliveryType type;
  final String title;
  final String description;
  final double charge;
  final String estimatedDays;
  final bool isAvailable;

  const DeliveryMethod({
    this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.charge,
    required this.estimatedDays,
    this.isAvailable = true,
  });

  String get chargeDisplay =>
      charge == 0 ? 'FREE' : '₹${charge.toStringAsFixed(0)}';

  static List<DeliveryMethod> getAll() => [
    const DeliveryMethod(
      type: DeliveryType.standard,
      title: 'STANDARD DELIVERY',
      description: 'Reliable ground shipping',
      charge: 0,
      estimatedDays: '5-7 business days',
    ),
    const DeliveryMethod(
      type: DeliveryType.express,
      title: 'EXPRESS DELIVERY',
      description: 'Priority air shipping',
      charge: 149,
      estimatedDays: '2-3 business days',
    ),
    const DeliveryMethod(
      type: DeliveryType.sameDay,
      title: 'SAME DAY DELIVERY',
      description: 'Available in select metro cities',
      charge: 299,
      estimatedDays: 'Today',
      isAvailable: false,
    ),
  ];

  factory DeliveryMethod.fromJson(Map<String, dynamic> json) {
    // Parse type from string
    DeliveryType parsedType = DeliveryType.standard;
    final typeStr = json['type'] as String?;
    if (typeStr == 'express') parsedType = DeliveryType.express;
    if (typeStr == 'sameDay') parsedType = DeliveryType.sameDay;

    return DeliveryMethod(
      id: json['id'] as String?,
      type: parsedType,
      title: json['title'] as String,
      description: json['description'] as String,
      charge: (json['charge'] as num).toDouble(),
      estimatedDays: json['estimated_days'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}
