import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vet_model.dart';
import '../config/constants/environment.dart';


class VetService {
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // GET /veterinarias con filtros
  Future<List<Veterinaria>> getVeterinarias({
    String? busqueda, 
    bool? soloAbierto
  }) async {
    
    // Construimos la URL con parámetros query
    // Ejemplo: /veterinarias?busqueda=texto&abierto=true
    var queryParams = <String, String>{};
    if (busqueda != null && busqueda.isNotEmpty) {
      queryParams['busqueda'] = busqueda;
    }
    if (soloAbierto == true) {
      queryParams['abierto'] = 'true';
    }

    // Usamos Uri.http para armar la URL correctamente con parámetros
    // Nota: Como Environment.baseUrl ya tiene 'http://...', aquí hay que tener cuidado.
    // Lo haremos manual para no complicarnos con el parseo del authority.
    
    String urlString = '${Environment.baseUrl}/veterinarias';
    // Agregamos params manualmente si existen
    if (queryParams.isNotEmpty) {
      final uri = Uri(queryParameters: queryParams);
      urlString += "?${uri.query}";
    }

    final url = Uri.parse(urlString);

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Veterinaria.fromJson(json)).toList();
      } else {
        print('Error veterinarias: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error conexión veterinarias: $e');
      return [];
    }
  }
  // GET /veterinarias/{id}
  Future<VeterinariaDetalle?> getVeterinariaDetalle(int id) async {
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$id');

    try {
      final headers = await _getHeaders();

      print("Pidiendo detalle a: $url"); // <--- DEBUG 1
      final response = await http.get(url, headers: headers);
      print("Respuesta Detalle: ${response.statusCode}"); // <--- DEBUG 2
      print("Cuerpo Detalle: ${response.body}"); // <--- DEBUG 3

      if (response.statusCode == 200) {
        return VeterinariaDetalle.fromJson(jsonDecode(response.body));
      } else {
        return null;
      }
    } catch (e) {
      print('Error detalle vet: $e');
      print('Error CRÍTICO detalle vet: $e'); // <--- DEBUG 4
      return null;
    }
  }
}