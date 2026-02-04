import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_member.dart';
import '../services/family_storage.dart';
import '../services/local_database.dart';
import 'auth_provider.dart';

final familyMembersProvider = StateNotifierProvider<FamilyMembersNotifier,
    AsyncValue<List<FamilyMember>>>((ref) {
  final authState = ref.watch(authProvider);
  return FamilyMembersNotifier(
    accountId: authState.value?.accountId,
  );
});

class FamilyMembersNotifier
    extends StateNotifier<AsyncValue<List<FamilyMember>>> {
  final String? accountId;

  FamilyMembersNotifier({this.accountId}) : super(const AsyncValue.loading()) {
    _loadMembers();
  }

  Future<void> addMember({
    required String name,
    required String relation,
    String? phone,
    String? email,
    String? parentId,
    String? loggedInMemberId,
  }) async {
    if (relation.trim().toLowerCase() == 'self' && loggedInMemberId != null) {
      final members = await FamilyStorage.readMembers(accountId: accountId);
      final existingSelf = members.firstWhere(
        (m) =>
            m.memberId == loggedInMemberId &&
            m.relation.trim().toLowerCase() == 'self',
        orElse: () => null as dynamic,
      ) as FamilyMember?;

      if (existingSelf != null) {
        throw Exception(
            'You already have a "Self" profile. Each account can only have one primary profile. Add other family members with different relations (Parent, Child, Sibling, etc.)');
      }
    }

    // Get current user's familyId
    String? familyId;
    if (loggedInMemberId != null) {
      final db = LocalDatabase.instance;
      final currentMember = await db.getFamilyMemberById(loggedInMemberId);
      familyId = currentMember?.familyId;
    }

    await FamilyStorage.addMember(
      name: name,
      relation: relation,
      phone: phone,
      email: email,
      parentId: parentId,
      familyId: familyId,
    );
    await _loadMembers();
  }

  void refresh() {
    _loadMembers();
  }

  Future<void> removeMember(String id, {String? loggedInMemberId}) async {
    if (loggedInMemberId != null && id == loggedInMemberId) {
      throw Exception(
          'You cannot delete your own profile while logged in. Please log out first if you want to delete your account.');
    }
    await FamilyStorage.removeMember(id);
    await _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await FamilyStorage.readMembers(accountId: accountId);
      state = AsyncValue.data(members);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
