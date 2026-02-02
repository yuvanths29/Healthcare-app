import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_profile.dart';

class HealthStorage {
  static const String _storageKey = 'healthProfile.v1';

  static Future<HealthProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return HealthProfile();

    try {
      final parsed = jsonDecode(raw) as Map<String, dynamic>;
      return HealthProfile.fromJson(parsed);
    } catch (e) {
      return HealthProfile();
    }
  }

  static Future<void> saveProfile(HealthProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
  }
}
