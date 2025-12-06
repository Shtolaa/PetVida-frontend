import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_models.dart';
import '../config/constants/environment.dart';

class ProfileService {
  
  // Obtener Token y Headers
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Obtener ID del usuario guardado
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  // 1. Obtener Perfil (GET /usuarios/{id})
  Future<UsuarioPerfil?> getUserProfile() async {
    final userId = await _getUserId();
    if (userId.isEmpty) return null;

    final url = Uri.parse('${Environment.baseUrl}/usuarios/$userId');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return UsuarioPerfil.fromJson(jsonDecode(response.body));
      } else {
        print('Error perfil: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error conexión perfil: $e');
      return null;
    }
  }

  // 2. Cerrar Sesión (Borrar datos locales)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra token, user_id y cualquier otra cosa
  }
  // 3. Agregar Mascota (POST /mascotas)
  Future<bool> createMascota(Map<String, dynamic> mascotaData) async {
    final url = Uri.parse('${Environment.baseUrl}/mascotas');
    
    try {
      final headers = await _getHeaders();
      // Aseguramos que el usuarioId vaya en el cuerpo si la API lo pide explícitamente
      // aunque idealmente el backend debería sacarlo del Token.
      // Según tu OpenAPI, el body pide "usuarioId".
      final userId = await _getUserId();
      mascotaData['usuarioId'] = int.tryParse(userId) ?? 0;

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(mascotaData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error creando mascota: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error conexión crear mascota: $e');
      return false;
    }
  }
}