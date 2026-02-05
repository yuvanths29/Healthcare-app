import '../models/health_profile.dart';
import 'local_database.dart';

class HealthStorage {
  static Future<HealthProfile> getProfile({
    required String memberId,
  }) async {
    final db = LocalDatabase.instance;
    return await db.getHealthProfileByMemberId(memberId);
  }

  static Future<void> saveProfile({
    required String memberId,
    required HealthProfile profile,
  }) async {
    final db = LocalDatabase.instance;
    await db.upsertHealthProfile(memberId, profile);
  }
}
