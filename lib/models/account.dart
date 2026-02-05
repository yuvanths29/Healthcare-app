class Account {
  final String accountId;
  final String memberId;
  final String emailOrPhone;
  final String passwordHash;

  Account({
    required this.accountId,
    required this.memberId,
    required this.emailOrPhone,
    required this.passwordHash,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      accountId: map['accountId'] as String? ?? '',
      memberId: map['memberId'] as String? ?? '',
      emailOrPhone: map['emailOrPhone'] as String? ?? '',
      passwordHash: map['passwordHash'] as String? ?? '',
    );
  }

  Account copyWith({
    String? accountId,
    String? memberId,
    String? emailOrPhone,
    String? passwordHash,
  }) {
    return Account(
      accountId: accountId ?? this.accountId,
      memberId: memberId ?? this.memberId,
      emailOrPhone: emailOrPhone ?? this.emailOrPhone,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }

  Map<String, dynamic> toMap() => {
        'accountId': accountId,
        'memberId': memberId,
        'emailOrPhone': emailOrPhone,
        'passwordHash': passwordHash,
      };

  @override
  String toString() =>
      'Account(accountId: $accountId, memberId: $memberId, emailOrPhone: $emailOrPhone)';
}
