class UserEntity {
  final String id;
  final String email;
  final String username;
  final String role;

  const UserEntity({
    required this.id,
    required this.email,
    required this.username,
    this.role = 'user',
  });
}
