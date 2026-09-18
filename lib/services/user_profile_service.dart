import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileService extends ChangeNotifier {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  static const String keyName = 'splitpe_user_name';
  static const String keyUpiId = 'splitpe_user_upi_id';

  UserProfile? _profile;
  bool _isLoaded = false;
  final Map<String, String> _memoryFallback = {};

  UserProfile? get profile => _profile;
  bool get isLoaded => _isLoaded;
  bool get hasProfile => _profile != null && _profile!.isValid;

  Future<UserProfile?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(keyName) ?? _memoryFallback[keyName];
      final upiId = prefs.getString(keyUpiId) ?? _memoryFallback[keyUpiId];
      if (name != null && name.trim().isNotEmpty && upiId != null && upiId.trim().isNotEmpty) {
        _profile = UserProfile(name: name.trim(), upiId: upiId.trim());
      } else {
        _profile = null;
      }
    } catch (_) {
      final name = _memoryFallback[keyName];
      final upiId = _memoryFallback[keyUpiId];
      if (name != null && name.trim().isNotEmpty && upiId != null && upiId.trim().isNotEmpty) {
        _profile = UserProfile(name: name.trim(), upiId: upiId.trim());
      } else {
        _profile = null;
      }
    }
    _isLoaded = true;
    notifyListeners();
    return _profile;
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    _memoryFallback[keyName] = profile.name;
    _memoryFallback[keyUpiId] = profile.upiId;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyName, profile.name);
      await prefs.setString(keyUpiId, profile.upiId);
    } catch (_) {}
  }

  Future<void> clearProfile() async {
    _profile = null;
    _memoryFallback.remove(keyName);
    _memoryFallback.remove(keyUpiId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyName);
      await prefs.remove(keyUpiId);
    } catch (_) {}
  }
}
