import '../models/report_item.dart';

class ReportStorageImpl {
  static Future<List<ReportItem>> listReports({required String userId}) async {
    return [];
  }

  static Future<ReportItem> addReport({
    required String userId,
    required String category,
    required String sourcePath,
    required String originalName,
  }) {
    throw UnsupportedError(
        'Local report storage is not available on this platform.');
  }

  static Future<void> deleteReport({
    required String userId,
    required String reportId,
  }) {
    throw UnsupportedError(
        'Local report storage is not available on this platform.');
  }
}
