import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; 
import '../models/auth_models.dart';
import '../config/constants/environment.dart';

class AuthService {
  


  Future<bool> login(String email, String password) async {
    final url = Uri.parse('${Environment.baseUrl}/auth/login');
    
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(LoginRequest(email: email, password: password).toJson()),
      );

      if (response.statusCode == 200) {
        final data = LoginResponse.fromJson(jsonDecode(response.body));
        
        Map<String, dynamic> decodedToken = JwtDecoder.decode(data.token);
        
        // 1. Obtener ID (Ya lo teníamos)
        String userId = decodedToken['id']?.toString() 
            ?? decodedToken['userId']?.toString() 
            ?? decodedToken['sub'] 
            ?? '';

        // 2. NUEVO: Obtener ROL
        // Revisa en tu consola cómo viene el rol. Usualmente es 'role', 'roles' o 'authorities'.
        // Asumiremos 'role' por tu JSON de registro.
        String role = decodedToken['role']?.toString() ?? 'CLIENTE'; 
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data.token);
        await prefs.setString('user_id', userId);
        await prefs.setString('user_role', role); // <--- GUARDAMOS EL ROL
        
        return true;
      } else {
        print('Error Login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // Método helper para obtener el ID guardado (lo usaremos en el Home)
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }
  Future<String> getUserRole() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_role') ?? 'CLIENTE';
}
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
  }
}