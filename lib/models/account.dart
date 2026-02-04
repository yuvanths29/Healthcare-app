class Account {
  final String accountId;
  final String memberId;
  final String email;
  final String phone;
  final String passwordHash;

  Account({
    required this.accountId,
    required this.memberId,
    required this.email,
    required this.phone,
    required this.passwordHash,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      accountId: map['accountId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
    );
  }

  Account copyWith({
    String? accountId,
    String? memberId,
    String? email,
    String? phone,
    String? passwordHash,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      memberId: memberId ?? this.memberId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  Map<String, dynamic> toMap() => {
        'accountId': accountId,
        'memberId': memberId,
        'email': email,
        'phone': phone,
        'passwordHash': passwordHash,
      };

  @override
  String toString() =>
      'Account(accountId: $accountId, memberId: $memberId, email: $email, phone: $phone)';
}
