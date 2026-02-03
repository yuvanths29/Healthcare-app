class ReportItem {
  final String id;
  final String userId;
  final String category;
  final String originalName;
  final String storedPath;
  final int createdAtMs;

  const ReportItem({
    required this.id,
    required this.userId,
    required this.category,
    required this.originalName,
    required this.storedPath,
    required this.createdAtMs,
  });

  factory ReportItem.fromJson(Map<String, dynamic> json) => ReportItem(
        id: json['id'] as String? ?? '',
        userId: json['userId'] as String? ?? '',
        category: json['category'] as String? ?? '',
        originalName: json['originalName'] as String? ?? '',
        storedPath: json['storedPath'] as String? ?? '',
        createdAtMs: json['createdAtMs'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'category': category,
        'originalName': originalName,
        'storedPath': storedPath,
        'createdAtMs': createdAtMs,
      };
}
