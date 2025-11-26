class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final String lastName;
  final List<String> roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.name,
    required this.lastName,
    required this.roles,
  });

  bool hasRole(String role) {
    return roles.contains(role);
  }

  bool get isAdmin => hasRole('ADMIN');
}
