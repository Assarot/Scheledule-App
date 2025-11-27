import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';

class AuthLocalDataSource {
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUser = 'user';
  static const String _keyRememberMe = 'remember_me';

  final FlutterSecureStorage secureStorage;
  final Future<SharedPreferences> prefsInstance;

  AuthLocalDataSource({
    FlutterSecureStorage? secureStorage,
    Future<SharedPreferences>? sharedPreferences,
  }) : secureStorage = secureStorage ?? const FlutterSecureStorage(),
       prefsInstance = sharedPreferences ?? SharedPreferences.getInstance();

  // Access Token (memoria segura)
  Future<void> saveAccessToken(String token) async {
    await secureStorage.write(key: _keyAccessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _keyAccessToken);
  }

  Future<void> deleteAccessToken() async {
    await secureStorage.delete(key: _keyAccessToken);
  }

  // Refresh Token (memoria segura)
  Future<void> saveRefreshToken(String token) async {
    await secureStorage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _keyRefreshToken);
  }

  Future<void> deleteRefreshToken() async {
    await secureStorage.delete(key: _keyRefreshToken);
  }

  // User (SharedPreferences para acceso rápido)
  Future<void> saveUser(UserModel user) async {
    final prefs = await prefsInstance;
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await prefsInstance;
    final userJson = prefs.getString(_keyUser);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<void> deleteUser() async {
    final prefs = await prefsInstance;
    await prefs.remove(_keyUser);
  }

  // Remember Me
  Future<void> saveRememberMe(bool rememberMe) async {
    final prefs = await prefsInstance;
    await prefs.setBool(_keyRememberMe, rememberMe);
  }

  Future<bool> getRememberMe() async {
    final prefs = await prefsInstance;
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  // Clear All
  Future<void> clearAll() async {
    await deleteAccessToken();
    await deleteRefreshToken();
    await deleteUser();
    final prefs = await prefsInstance;
    await prefs.remove(_keyRememberMe);
  }
}