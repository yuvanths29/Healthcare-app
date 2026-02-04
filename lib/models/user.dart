class Session {
  final String userId;
  final String accountId;
  final String name;
  final String email;
  final String mobile;
  final String? memberId;

  Session({
    required this.userId,
    required this.accountId,
    required this.name,
    required this.email,
    required this.mobile,
    this.memberId,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        userId: json['userId'] as String? ?? '',
        accountId: json['accountId'] as String? ?? json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        memberId: json['memberId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'accountId': accountId,
        'name': name,
        'email': email,
        'mobile': mobile,
        'memberId': memberId,
      };
}

class User {
  final String userId;
  final String name;
  final String email;
  final String mobile;
  final String password;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
  });

  /// Factory constructor for creating User from database query result
  factory User.fromDbJson(Map<String, dynamic> json) => User(
        userId: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        userId: json['userId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        password: json['password'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
      };
}
