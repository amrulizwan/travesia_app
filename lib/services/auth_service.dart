import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://v2.aisadev.id/api';
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  static Future<AuthService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService(prefs);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveAuthData(
          data['token'],
          data['refreshToken'],
          data['user'],
        );

        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    String role = 'pengunjung',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
      };
    }
  }

  Future<void> _saveAuthData(
    String token,
    String refreshToken,
    Map<String, dynamic> userData,
  ) async {
    await _prefs.setString(tokenKey, token);
    await _prefs.setString(refreshTokenKey, refreshToken);
    await _prefs.setString(userKey, jsonEncode(userData));
  }

  Future<void> logout() async {
    await _prefs.remove(tokenKey);
    await _prefs.remove(refreshTokenKey);
    await _prefs.remove(userKey);
  }

  bool get isLoggedIn => _prefs.containsKey(tokenKey);

  String? get token => _prefs.getString(tokenKey);

  String? get refreshToken => _prefs.getString(refreshTokenKey);

  Map<String, dynamic>? get userData {
    final userStr = _prefs.getString(userKey);
    if (userStr == null) return null;
    return jsonDecode(userStr) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> requestResetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/request-reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
      };
    }
  }

  Future<Map<String, dynamic>> verifyResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-reset-password'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan pada server',
      };
    }
  }
}
