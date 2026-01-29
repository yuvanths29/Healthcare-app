import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_member.dart';

class FamilyStorage {
  static const String _storageKey = 'familyMembers.v1';

  static String _createMemberId() {
    final rand = (DateTime.now().microsecond % 10000).toRadixString(36).toUpperCase();
    final time = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'F-$time-$rand';
  }

  static Future<List<FamilyMember>> readMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    try {
      final List<dynamic> parsed = jsonDecode(raw);
      return parsed
          .where((item) => item is Map<String, dynamic>)
          .map((item) => FamilyMember.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> writeMembers(List<FamilyMember> members) async {
    final prefs = await SharedPreferences.getInstance();
    final data = members.map((m) => m.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  static Future<void> addMember({
    required String name,
    required String relation,
    String? age,
  }) async {
    final members = await readMembers();
    final newMember = FamilyMember(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: _createMemberId(),
      name: name,
      relation: relation,
      age: age,
    );
    await writeMembers([newMember, ...members]);
  }

  static Future<void> removeMember(String id) async {
    final members = await readMembers();
    final updated = members.where((m) => m.id != id).toList();
    await writeMembers(updated);
  }
}
