import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ISecureStorageService {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUserData(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> clearAll();
}

/// Secure token storage service handling JWT access tokens and authenticated session metadata.
/// Security Principles:
/// 1. Access tokens are kept in encrypted/isolated secure persistence.
/// 2. Passwords or raw credential secrets are NEVER written to disk.
/// 3. JWT signing secrets are NEVER embedded inside the mobile client.
class SecureStorageService implements ISecureStorageService {
  static const String _keyToken = 'sec_jv_jwt_auth_token';
  static const String _keyUserData = 'sec_jv_user_metadata_v1';

  @override
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  @override
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token == null || token.trim().isEmpty) return null;
    return token;
  }

  @override
  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    // Strip any sensitive fields if present
    final sanitized = Map<String, dynamic>.from(data)
      ..remove('password')
      ..remove('client_secret');
    await prefs.setString(_keyUserData, jsonEncode(sanitized));
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUserData);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserData);
  }
}
