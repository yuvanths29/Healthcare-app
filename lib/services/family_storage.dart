import '../models/family_member.dart';
import 'local_database.dart';

class FamilyStorage {
  static Future<void> addMember({
    required String name,
    required String relation,
    String? phone,
    String? email,
    String? parentId,
    String? familyId,
  }) async {
    final db = LocalDatabase.instance;
    final newMember = FamilyMember(
      memberId: _createMemberId(),
      familyId: familyId ?? _createFamilyId(),
      name: name,
      relation: relation,
      parentId: parentId,
      phone: phone,
      email: email,
      hasAccount: false,
    );
    await db.insertFamilyMember(newMember);
  }

  static Future<List<FamilyMember>> readMembers({String? accountId}) async {
    final db = LocalDatabase.instance;
    if (accountId == null) {
      return [];
    }
    return await db.getFamilyMembersForCurrentAccount(accountId);
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

  static String _createFamilyId() {
    final rand =
        (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    final time =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'FAM-$time-$rand';
  }

  static String _createMemberId() {
    final rand =
        (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    final time =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'F-$time-$rand';
  }
}
