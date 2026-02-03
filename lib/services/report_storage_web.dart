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
      'File storage is not supported on Web in this app build. Run on Android/Windows/Desktop for local directories.',
    );
  }

  static Future<void> deleteReport({
    required String userId,
    required String reportId,
  }) {
    throw UnsupportedError('File storage is not supported on Web in this app build.');
  }
}
