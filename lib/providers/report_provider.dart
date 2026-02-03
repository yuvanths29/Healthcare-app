import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/report_item.dart';
import '../services/report_storage.dart';

final reportsProvider = StateNotifierProvider.family<ReportsNotifier,
    AsyncValue<List<ReportItem>>, String>((ref, userId) {
  return ReportsNotifier(userId: userId);
});

class ReportsNotifier extends StateNotifier<AsyncValue<List<ReportItem>>> {
  final String userId;

  ReportsNotifier({required this.userId}) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    try {
      final reports = await ReportStorage.listReports(userId: userId);
      state = AsyncValue.data(reports);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<ReportItem> addReport({
    required String category,
    required String sourcePath,
    required String originalName,
  }) async {
    final created = await ReportStorage.addReport(
      userId: userId,
      category: category,
      sourcePath: sourcePath,
      originalName: originalName,
    );
    await refresh();
    return created;
  }

  Future<void> deleteReport(String reportId) async {
    await ReportStorage.deleteReport(userId: userId, reportId: reportId);
    await refresh();
  }
}
