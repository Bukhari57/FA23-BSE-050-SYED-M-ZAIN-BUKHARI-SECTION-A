import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileService {
  static final ProfileService instance = ProfileService._init();
  static const String _profileKey = 'user_profile';

  ProfileService._init();

  Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    
    if (profileJson != null) {
      try {
        return UserProfile.fromJson(jsonDecode(profileJson));
      } catch (e) {
        return _getDefaultProfile();
      }
    }
    
    return _getDefaultProfile();
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_profileKey);
  }

  UserProfile _getDefaultProfile() {
    return UserProfile(
      name: 'User',
      bio: 'Tap to edit your bio',
    );
  }
}

