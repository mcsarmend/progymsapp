import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
      print('LOGIN URL: $loginURL');
      print('LOGIN EMAIL: $email');

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

      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE BODY: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('LOGIN CORRECTO');

        final prefs = await SharedPreferences.getInstance();

        final token = data['token']?.toString();

        print('TOKEN: $token');
        print('USER DATA: ${data['user']}');

        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'message': 'El servidor no devolvió un token.',
          };
        }

        try {
          final userData = Map<String, dynamic>.from(data['user']);

          print('USER DATA MAP: $userData');

          final user = User.fromJson(userData);

          print('USER PARSEADO CORRECTAMENTE');
          print('USER ID: ${user.id}');
          print('USER NAME: ${user.name}');
          print('USER EMAIL: ${user.email}');

          await prefs.setString(tokenKey, token);
          await prefs.setString(
            userKey,
            jsonEncode(data['user']),
          );

          print('DATOS GUARDADOS EN SHARED PREFERENCES');

          return {
            'success': true,
            'user': user,
            'token': token,
          };
        } catch (e, stackTrace) {
          print('ERROR AL CONVERTIR USER: $e');
          print(stackTrace);

          return {
            'success': false,
            'message': 'Error al procesar los datos del usuario.',
            'error': e.toString(),
          };
        }
      }

      String message = 'Error al iniciar sesión.';

      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Correo o contraseña incorrectos.';
      }

      print('ERROR LOGIN: $message');

      return {
        'success': false,
        'message': message,
      };
    } on TimeoutException catch (e) {
      print('TIMEOUT LOGIN: $e');

      return {
        'success': false,
        'message': 'El servidor tardó demasiado en responder.',
        'error': e.toString(),
      };
    } catch (e, stackTrace) {
      print('ERROR LOGIN: $e');
      print(stackTrace);

      return {
        'success': false,
        'message': 'Error al realizar el login.',
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

  Future<List<Map<String, dynamic>>> getPedidosRepartidor(
      int repartidorId) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    try {
      // La URL lleva el ID como parámetro GET como espera tu controlador
      final url = Uri.parse('$baseURL/pedidosrepartidor?id=$repartidorId');

      print('📦 URL pedidos: $url');
      print('📦 Token: $token');
      print('📦 Repartidor ID: $repartidorId');

      final response = await http.get(
        url,
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      print('📦 Status code: ${response.statusCode}');
      print('📦 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // data['data'] contiene la lista de pedidos
          final List<dynamic> pedidosData = data['data'] ?? [];
          return pedidosData
              .map((pedido) => Map<String, dynamic>.from(pedido))
              .toList();
        } else {
          throw Exception(data['message'] ?? 'Error al obtener pedidos');
        }
      }

      if (response.statusCode == 401) {
        await clearSession();
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      }

      throw Exception('Error del servidor: ${response.statusCode}');
    } on SocketException catch (e) {
      print('❌ Error de red: $e');
      throw Exception(
          'No se puede conectar al servidor. Verifica tu conexión a internet.');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('El servidor tardó demasiado en responder.');
    } catch (e) {
      print('❌ Error inesperado: $e');
      rethrow;
    }
  }

  Future<bool> cambiarEstadoPedido(int pedidoId, String nuevoEstatus) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    try {
      final url = Uri.parse('$baseURL/pedidoscambiarestado');

      // El body debe tener exactamente lo que espera tu controlador
      final body = jsonEncode({
        'id': pedidoId,
        'nuevoEstatus': nuevoEstatus,
      });

      print('🔄 URL cambio estado: $url');
      print('🔄 Body: $body');
      print('🔄 Token: $token');

      final response = await http
          .post(
            url,
            headers: {
              ...headers,
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      print('🔄 Status code: ${response.statusCode}');
      print('🔄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }

      if (response.statusCode == 401) {
        await clearSession();
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      }

      // Intentar obtener el mensaje de error del servidor
      String errorMessage = 'No se pudo cambiar el estado del pedido.';
      try {
        final data = jsonDecode(response.body);
        if (data['message'] != null) {
          errorMessage = data['message'];
        }
      } catch (_) {}

      throw Exception(errorMessage);
    } on SocketException catch (e) {
      print('❌ Error de red: $e');
      throw Exception(
          'No se puede conectar al servidor. Verifica tu conexión a internet.');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('El servidor tardó demasiado en responder.');
    } catch (e) {
      print('❌ Error inesperado: $e');
      rethrow;
    }
  }

  // Método para obtener un pedido específico (opcional)
  Future<Map<String, dynamic>?> getPedidoById(int pedidoId) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa.');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseURL/pedidos/$pedidoId'),
        headers: {
          ...headers,
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Map<String, dynamic>.from(data['data'] ?? {});
      }

      return null;
    } catch (e) {
      print('❌ Error al obtener pedido: $e');
      return null;
    }
  }
}
