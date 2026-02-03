class FamilyMember {
  final String memberId;
  final String name;
  final String relation;
  final String? parentId;
  final String? phone;
  final String? email;
  final bool hasAccount;

  FamilyMember({
    required this.memberId,
    required this.name,
    required this.relation,
    this.parentId,
    this.phone,
    this.email,
    this.hasAccount = false,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    final dynamic rawHasAccount = map['hasAccount'];
    final bool hasAcc = rawHasAccount is int
        ? rawHasAccount == 1
        : (rawHasAccount as bool? ?? false);

    return FamilyMember(
      memberId: map['memberId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      relation: map['relation'] as String? ?? '',
      parentId: map['parentId'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      hasAccount: hasAcc,
    );
  }

  FamilyMember copyWith({
    String? memberId,
    String? name,
    String? relation,
    String? parentId,
    String? phone,
    String? email,
    bool? hasAccount,
  }) {
    return FamilyMember(
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      parentId: parentId ?? this.parentId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      hasAccount: hasAccount ?? this.hasAccount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'memberId': memberId,
      'name': name,
      'relation': relation,
      'parentId': parentId,
      'phone': phone,
      'email': email,
      'hasAccount': hasAccount ? 1 : 0,
    };
  }

  @override
  String toString() =>
      'FamilyMember(memberId: $memberId, name: $name, relation: $relation, parentId: $parentId, phone: $phone, email: $email, hasAccount: $hasAccount)';
}
