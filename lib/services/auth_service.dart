import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

class AuthService {
  // CAMBIA SEGUN :
  // Emulador Android: 'http://10.0.2.2:8080'
  // Dispositivo físico: Tu IP local 'http://192.168.x.x:8080'
  // Si es web: 'http://localhost:8080'
  static const String baseUrl = 'http://10.0.2.2:8080'; 

  Future<bool> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(LoginRequest(email: email, password: password).toJson()),
      );

      if (response.statusCode == 200) {
        final data = LoginResponse.fromJson(jsonDecode(response.body));
        
        // Guardar el token en el dispositivo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data.token);
        
        return true; // Login exitoso
      } else {
        print('Error Login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }
}