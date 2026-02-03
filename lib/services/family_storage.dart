import '../models/family_member.dart';
import 'local_database.dart';

class FamilyStorage {
  static Future<void> addMember({
    required String name,
    required String relation,
    String? phone,
    String? email,
    String? parentId,
  }) async {
    final db = LocalDatabase.instance;
    final newMember = FamilyMember(
      memberId: _createMemberId(),
      name: name,
      relation: relation,
      parentId: parentId,
      phone: phone,
      email: email,
      hasAccount: false,
    );
    await db.insertFamilyMember(newMember);
  }

  static Future<List<FamilyMember>> readMembers() async {
    final db = LocalDatabase.instance;
    return await db.getAllFamilyMembers();
  }

  static Future<void> removeMember(String memberId) async {
    final db = LocalDatabase.instance;
    await db.deleteFamilyMember(memberId);
  }

  static Future<void> writeMembers(List<FamilyMember> members) async {
    final db = LocalDatabase.instance;
    for (final member in members) {
      await db.updateFamilyMember(member);
    }
  }

  static String _createMemberId() {
    final rand =
        (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    final time =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'F-$time-$rand';
  }
}
