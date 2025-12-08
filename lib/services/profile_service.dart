import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_models.dart';
import '../config/constants/environment.dart';
import 'dart:io';

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

    final url = Uri.parse('${Environment.baseUrl}/usuario/$userId');

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
// 3. Agregar Mascota (POST /mascotas con Multipart, ID auto y FOTO)
  Future<bool> createMascota(Map<String, dynamic> mascotaData, File? imagenFile) async { // <--- 1. Nuevo parámetro
    final url = Uri.parse('${Environment.baseUrl}/mascotas');
    
    try {
      // OBTENEMOS TOKEN Y USER ID
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';
      final userIdStr = prefs.getString('user_id');

      if (userIdStr == null) {
        print("ERROR CRÍTICO: No se encontró el ID del usuario.");
        return false;
      }
      final int ownerId = int.parse(userIdStr);

      // PREPARAMOS LA PETICIÓN
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';

      // DATOS JSON
      final datosParaJava = {
        "name": mascotaData['nombre'],
        "species": mascotaData['especie'], 
        "breed": mascotaData['raza'],
        "gender": mascotaData['genero'],
        "birthDate": mascotaData['fechaNacimiento'],
        "ownerId": ownerId 
      };
      request.fields['data'] = jsonEncode(datosParaJava);

      // --- 2. LÓGICA NUEVA: ADJUNTAR LA IMAGEN ---
      if (imagenFile != null) {
        // 'imagen' debe coincidir con @RequestPart("imagen") del Backend
        request.files.add(await http.MultipartFile.fromPath(
          'imagen', 
          imagenFile.path
        ));
      }
      // -------------------------------------------

      // ENVIAR
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error creando mascota (Back): ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error conexión crear mascota: $e');
      return false;
    }
  }
  // 4. Modificar Perfil Usuario (PATCH /usuario/{id})
  // Nota: Tu backend pide "multipart/form-data" con un campo 'data' y un 'file' opcional.
  Future<bool> updateProfile(String nombre, String email) async {
    final userId = await _getUserId();
    final url = Uri.parse('${Environment.baseUrl}/usuario/$userId');
    final token = (await SharedPreferences.getInstance()).getString('jwt_token') ?? '';

    try {
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Tu backend espera un JSON string dentro de un campo llamado "data"
      request.fields['data'] = jsonEncode({
        "fullName": nombre,
        "email": email,
        // "telefono": telefono // Si el back lo agrega después
      });

      // TODO: Si implementas subida de imagen, aquí iría:
      // request.files.add(await http.MultipartFile.fromPath('file', pathImagen));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error update profile: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error conexión update profile: $e');
      return false;
    }
  }

// 5. Modificar Mascota (PATCH con FOTO)
  Future<bool> updateMascota(int mascotaId, Map<String, dynamic> datos, File? imagenFile) async {
    final url = Uri.parse('${Environment.baseUrl}/mascotas/$mascotaId');
    final token = (await SharedPreferences.getInstance()).getString('jwt_token') ?? '';

    try {
      var request = http.MultipartRequest('PATCH', url);
      request.headers['Authorization'] = 'Bearer $token';

      // Datos JSON
      final datosParaJava = {
        "nombre": datos['nombre'],
        "especie": datos['especie'],
        "raza": datos['raza'],
        "genero": datos['genero'],
        "fechaNacimiento": datos['fechaNacimiento']
      };
      request.fields['data'] = jsonEncode(datosParaJava);

      // ADJUNTAR FOTO (Si hay nueva)
      if (imagenFile != null) {
        // OJO: El backend 'PetController.updatePet' espera "file", NO "imagen"
        request.files.add(await http.MultipartFile.fromPath(
          'file', // <--- Nombre clave correcto según tu Java
          imagenFile.path
        ));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error update mascota: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error conexión update: $e');
      return false;
    }
  }
}