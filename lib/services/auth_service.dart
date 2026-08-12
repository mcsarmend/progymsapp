import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../constant.dart';

class AuthService {
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(loginURL),
            headers: {
              ...headers,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();

        final token = data['token']?.toString();

        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'message': 'El servidor no devolvió un token.',
          };
        }

        final user = User.fromJson(
          Map<String, dynamic>.from(data['user']),
        );

        await prefs.setString(tokenKey, token);
        await prefs.setString(
          userKey,
          jsonEncode(data['user']),
        );

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      }

      String message = 'Error al iniciar sesión.';

      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Correo o contraseña incorrectos.';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'No se pudo conectar con el servidor.',
        'error': e.toString(),
      };
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(tokenKey);

    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);

    if (userData == null || userData.isEmpty) {
      return null;
    }

    try {
      return User.fromJson(
        Map<String, dynamic>.from(
          jsonDecode(userData),
        ),
      );
    } catch (e) {
      await prefs.remove(userKey);
      return null;
    }
  }

  Future<User?> getUser() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse(userURL),
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final user = User.fromJson(
          Map<String, dynamic>.from(data['user']),
        );

        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(
          userKey,
          jsonEncode(data['user']),
        );

        return user;
      }

      if (response.statusCode == 401) {
        await clearSession();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> logout() async {
    final token = await getToken();

    try {
      if (token != null && token.isNotEmpty) {
        await http.post(
          Uri.parse(logoutURL),
          headers: {
            ...headers,
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      // Aunque el servidor no responda,
      // se elimina la sesión local.
    }

    await clearSession();

    return true;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}
