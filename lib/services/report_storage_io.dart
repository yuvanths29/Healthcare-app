import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/report_item.dart';

class ReportStorageImpl {
  static String _reportsKey(String userId) => 'reports.$userId.v1';

  static Future<Directory> _userCategoryDir({
    required String userId,
    required String category,
  }) async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, 'reports', userId, category));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<List<ReportItem>> listReports({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_reportsKey(userId));
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final parsed = jsonDecode(raw);
      if (parsed is! List) return [];
      return parsed
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .map(ReportItem.fromJson)
          .where((r) => r.userId == userId)
          .toList(growable: true);
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveReports(String userId, List<ReportItem> reports) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(reports.map((r) => r.toJson()).toList());
    await prefs.setString(_reportsKey(userId), raw);
  }

  static Future<ReportItem> addReport({
    required String userId,
    required String category,
    required String sourcePath,
    required String originalName,
  }) async {
    final src = File(sourcePath);
    if (!await src.exists()) {
      throw StateError('Selected file does not exist');
    }

    final reports = await listReports(userId: userId);

    final createdAt = DateTime.now().millisecondsSinceEpoch;
    final id = 'R-${createdAt.toRadixString(36).toUpperCase()}';

    final ext = p.extension(originalName).trim();
    final safeExt = ext.isEmpty ? p.extension(sourcePath) : ext;
    final fileName = '$id$safeExt';

    final destDir = await _userCategoryDir(userId: userId, category: category);
    final destPath = p.join(destDir.path, fileName);
    await src.copy(destPath);

    final item = ReportItem(
      id: id,
      userId: userId,
      category: category,
      originalName: originalName,
      storedPath: destPath,
      createdAtMs: createdAt,
    );

    reports.insert(0, item);
    await _saveReports(userId, reports);
    return item;
  }

  static Future<void> deleteReport({
    required String userId,
    required String reportId,
  }) async {
    final reports = await listReports(userId: userId);
    final target = reports.where((r) => r.id == reportId).firstOrNull;

    final updated = reports.where((r) => r.id != reportId).toList();
    await _saveReports(userId, updated);

    final path = target?.storedPath;
    if (path == null || path.isEmpty) return;

    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
  }
}

extension _FirstOrNullX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
