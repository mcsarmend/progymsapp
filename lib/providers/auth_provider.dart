// lib/providers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userName;
  String? _userEmail;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  // Getters
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    // Cargar token guardado si existe
    _loadSavedToken();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await http.post(
        Uri.parse(loginURL),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];

        // Extraer información del usuario
        if (data['user'] != null) {
          _userName = data['user']['name'] ?? '';
          _userEmail = data['user']['email'] ?? '';
        }

        _isAuthenticated = true;
        _setLoading(false);

        // Guardar token en SharedPreferences aquí si deseas
        // await _saveToken(_token!);

        return true;
      } else if (response.statusCode == 403) {
        final data = jsonDecode(response.body);
        _errorMessage = data['message'] ?? 'Credenciales incorrectas';
        _setLoading(false);
        return false;
      } else {
        _errorMessage =
            'Error al iniciar sesión. Código: ${response.statusCode}';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage =
          'Error de conexión. Verifica que el servidor esté activo.';
      _setLoading(false);
      print('Error en login: $e');
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _loadSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _isAuthenticated = true;
      // Aquí podrías cargar los datos del usuario
    }
  }

  void logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse(logoutURL),
          headers: {
            ...headers,
            'Authorization': 'Bearer $_token',
          },
        );
      }
    } catch (e) {
      print('Error en logout: $e');
    }

    _token = null;
    _userName = null;
    _userEmail = null;
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
