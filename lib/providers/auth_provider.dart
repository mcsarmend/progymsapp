// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // Estados del provider
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  String? _userEmail;
  String? _userName;
  String? _token;
  String? _userRole;

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get token => _token;
  String? get userRole => _userRole;

  // Usuario específico para la app de repartidores
  final Map<String, Map<String, String>> _validUsers = {
    'clemente.zarraga@progyms.com': <String, String>{
      'password': r'Progyms123$',
      'name': 'Clemente Zárraga',
      'role': 'delivery',
      'id': 'REP-001',
      'phone': '+52 55 1234 5678',
    },
  };

  // Método de Login
  Future<bool> login(String email, String password) async {
    // Limpiar estados anteriores
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simular delay de conexión
      await Future.delayed(const Duration(seconds: 2));

      // Validar credenciales
      final userData = _validUsers[email];
      
      if (userData != null && userData['password'] == password) {
        // Login exitoso
        _isAuthenticated = true;
        _userEmail = email;
        _userName = userData['name'] ?? 'Repartidor';
        _userRole = userData['role'] ?? 'delivery';
        _token = 'token_${DateTime.now().millisecondsSinceEpoch}';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // Login fallido
        _errorMessage = 'Credenciales incorrectas. Verifica tu correo y contraseña.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Error inesperado
      _errorMessage = 'Ocurrió un error al iniciar sesión. Intenta nuevamente.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Método para limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método de Logout
  void logout() {
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Método para resetear todo el estado
  void resetState() {
    _isLoading = false;
    _isAuthenticated = false;
    _errorMessage = null;
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _token = null;
    notifyListeners();
  }
}