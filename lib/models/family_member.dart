class FamilyMember {
  final String id;
  final String memberId;
  final String name;
  final String relation;
  final String? age;
  final String? latestCheckupDate;
  final List<String> latestReports;

  FamilyMember({
    required this.id,
    required this.memberId,
    required this.name,
    required this.relation,
    this.age,
    this.latestCheckupDate,
    this.latestReports = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'name': name,
        'relation': relation,
        if (age != null) 'age': age,
        if (latestCheckupDate != null) 'latestCheckupDate': latestCheckupDate,
        'latestReports': latestReports,
      };

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        id: json['id'] as String? ?? '',
        memberId: json['memberId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        relation: json['relation'] as String? ?? '',
        age: json['age'] as String?,
        latestCheckupDate: json['latestCheckupDate'] as String?,
        latestReports: (json['latestReports'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
