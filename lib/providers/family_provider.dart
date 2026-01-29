import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member.dart';
import '../services/family_storage.dart';

final familyMembersProvider = StateNotifierProvider<FamilyMembersNotifier, AsyncValue<List<FamilyMember>>>((ref) {
  return FamilyMembersNotifier();
});

class FamilyMembersNotifier extends StateNotifier<AsyncValue<List<FamilyMember>>> {
  FamilyMembersNotifier() : super(const AsyncValue.loading()) {
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final members = await FamilyStorage.readMembers();
      state = AsyncValue.data(members);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addMember({
    required String name,
    required String relation,
    String? age,
  }) async {
    await FamilyStorage.addMember(name: name, relation: relation, age: age);
    await _loadMembers();
  }

  Future<void> removeMember(String id) async {
    await FamilyStorage.removeMember(id);
    await _loadMembers();
  }

  void refresh() {
    _loadMembers();
  }
}
