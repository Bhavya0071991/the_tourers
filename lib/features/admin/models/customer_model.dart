class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime joinedAt;
  final int totalOrders;
  final double totalSpent;
  final String role;

  const CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joinedAt,
    required this.totalOrders,
    required this.totalSpent,
    this.role = 'user',
  });
}

// Mock Data
final List<CustomerModel> mockCustomers = [
  CustomerModel(
    id: 'CUST_001',
    name: 'BHAVY DEVELOPER',
    email: 'bhavy@example.com',
    phone: '+91 98765 43210',
    joinedAt: DateTime.now().subtract(const Duration(days: 45)),
    totalOrders: 3,
    totalSpent: 10450.0,
  ),
  CustomerModel(
    id: 'CUST_002',
    name: 'JOHN DOE',
    email: 'john@example.com',
    phone: '+1 555 1234',
    joinedAt: DateTime.now().subtract(const Duration(days: 120)),
    totalOrders: 1,
    totalSpent: 2999.0,
  ),
  CustomerModel(
    id: 'CUST_003',
    name: 'ALICE SMITH',
    email: 'alice.s@example.com',
    phone: '+44 7700 900077',
    joinedAt: DateTime.now().subtract(const Duration(days: 12)),
    totalOrders: 5,
    totalSpent: 15600.50,
  ),
  CustomerModel(
    id: 'CUST_004',
    name: 'TEST USER',
    email: 'test@test.com',
    phone: '+91 99999 00000',
    joinedAt: DateTime.now().subtract(const Duration(days: 2)),
    totalOrders: 0,
    totalSpent: 0.0,
  ),
];
