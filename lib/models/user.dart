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

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'password': password,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );
}

class Session {
  final String userId;
  final String name;
  final String email;

  Session({
    required this.userId,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
      );
}
