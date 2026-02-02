import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/health_profile.dart';
import '../services/health_storage.dart';

final healthProfileProvider =
    StateNotifierProvider<HealthProfileNotifier, AsyncValue<HealthProfile>>(
        (ref) {
  return HealthProfileNotifier();
});

class HealthProfileNotifier extends StateNotifier<AsyncValue<HealthProfile>> {
  HealthProfileNotifier() : super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await HealthStorage.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(HealthProfile profile) async {
    try {
      await HealthStorage.saveProfile(profile);
      state = AsyncValue.data(profile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void refresh() {
    _loadProfile();
  }
}
