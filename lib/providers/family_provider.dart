import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_member.dart';
import '../services/family_storage.dart';

final familyMembersProvider = StateNotifierProvider<FamilyMembersNotifier,
    AsyncValue<List<FamilyMember>>>((ref) {
  return FamilyMembersNotifier();
});

class FamilyMembersNotifier
    extends StateNotifier<AsyncValue<List<FamilyMember>>> {
  FamilyMembersNotifier() : super(const AsyncValue.loading()) {
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
      final members = await FamilyStorage.readMembers();
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

    await FamilyStorage.addMember(
      name: name,
      relation: relation,
      phone: phone,
      email: email,
      parentId: parentId,
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
      final members = await FamilyStorage.readMembers();
      state = AsyncValue.data(members);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
