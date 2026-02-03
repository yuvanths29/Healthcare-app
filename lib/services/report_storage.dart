import '../models/report_item.dart';

import 'report_storage_impl.dart' as impl;

class ReportStorage {
  static Future<List<ReportItem>> listReports({required String userId}) {
    return impl.ReportStorageImpl.listReports(userId: userId);
  }

  static Future<ReportItem> addReport({
    required String userId,
    required String category,
    required String sourcePath,
    required String originalName,
  }) {
    return impl.ReportStorageImpl.addReport(
      userId: userId,
      category: category,
      sourcePath: sourcePath,
      originalName: originalName,
    );
  }

  static Future<void> deleteReport({
    required String userId,
    required String reportId,
  }) {
    return impl.ReportStorageImpl.deleteReport(userId: userId, reportId: reportId);
  }
}
