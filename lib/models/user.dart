class User {
  final String id;
  final String email;
  final String password;
  final String username;
  final String role; // 'doctor' or 'patient'

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.username,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> map, String id) {
    return User(
      id: id,
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      username: map['username'] ?? '',
      role: map['role'] ?? 'patient',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'role': role,
    };
  }
}
