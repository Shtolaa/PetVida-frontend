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
        
        // 1. Decodificar el token para obtener los datos ocultos
        Map<String, dynamic> decodedToken = JwtDecoder.decode(data.token);
        
        // IMPRIMIR PARA DEBUGGEAR:
        // Así verás en consola exactamente cómo se llama el campo del ID en tu backend
        print("Payload del Token: $decodedToken");

        // 2. Extraer el ID. 
        // IMPORTANTE: Revisa tu consola. Spring Boot suele poner el usuario en "sub" 
        // o en un campo custom como "userId" o "id". 
        // Aquí asumiré que viene como "id" o "userId", si falla, cambiaremos esta línea.
        String userId = decodedToken['id']?.toString() ?? decodedToken['userId']?.toString() ?? decodedToken['sub'] ?? '';
        
        // 3. Guardar Token y UserID en el dispositivo
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data.token);
        await prefs.setString('user_id', userId); // <-- Guardamos el ID
        
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

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_id');
  }
}