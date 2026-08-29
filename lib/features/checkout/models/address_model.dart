class Address {
  final String id;
  final String fullName;
  final String phone;
  final String addressLine;
  final String landmark;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  const Address({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.addressLine,
    this.landmark = '',
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  Address copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? addressLine,
    String? landmark,
    String? city,
    String? state,
    String? pincode,
    bool? isDefault,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      addressLine: addressLine ?? this.addressLine,
      landmark: landmark ?? this.landmark,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  String get formattedAddress {
    final parts = [addressLine];
    if (landmark.isNotEmpty) parts.add(landmark);
    parts.addAll([city, state, pincode]);
    return parts.join(', ');
  }

  String get shortAddress => '$city, $state - $pincode';

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      addressLine: json['address_line'] as String,
      landmark: json['landmark'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson(String userId) {
    return {
      if (!id.startsWith('addr_')) 'id': id, // Don't send fake local IDs
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'address_line': addressLine,
      'landmark': landmark,
      'city': city,
      'state': state,
      'pincode': pincode,
      'is_default': isDefault,
    };
  }
}
