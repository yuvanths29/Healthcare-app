class Session {
  final String userId;
  final String name;
  final String email;

  Session({
    required this.userId,
    required this.name,
    required this.email,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
      };
}

class User {
  final String userId;
  final String name;
  final String email;
  final String password;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.password,
  });

  /// Factory constructor for creating User from database query result
  factory User.fromDbJson(Map<String, dynamic> json) => User(
        userId: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'password': password,
      };
}
