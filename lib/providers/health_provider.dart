import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_profile.dart';
import '../services/health_storage.dart';
import 'auth_provider.dart';

final healthProfileProvider =
    StateNotifierProvider<HealthProfileNotifier, AsyncValue<HealthProfile>>(
        (ref) {
  final authState = ref.watch(authProvider);
  return HealthProfileNotifier(authState.value?.memberId);
});

class HealthProfileNotifier extends StateNotifier<AsyncValue<HealthProfile>> {
  final String? memberId;

  HealthProfileNotifier(this.memberId) : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentMemberId = memberId;
      if (currentMemberId == null || currentMemberId.isEmpty) {
        state = AsyncValue.data(HealthProfile());
        return;
      }
      final profile = await HealthStorage.getProfile(memberId: currentMemberId);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(HealthProfile profile) async {
    try {
      final currentMemberId = memberId;
      if (currentMemberId == null || currentMemberId.isEmpty) {
        state = AsyncValue.data(HealthProfile());
        return;
      }
      await HealthStorage.saveProfile(
        memberId: currentMemberId,
        profile: profile,
      );
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() {
    _loadProfile();
  }
}
