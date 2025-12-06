import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/home_models.dart';
import '../config/constants/environment.dart';

class HomeService {
  
  // Helper para obtener cabeceras con Token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // Helper para obtener el ID guardado
  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  // 1. Obtener Citas Próximas (Automático)
  Future<List<CitaAgendada>> getProximasCitas() async {
    final userId = await _getUserId();
    if (userId.isEmpty) return [];

    final url = Uri.parse('${Environment.baseUrl}/citas/proximas/$userId');
    
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CitaAgendada.fromJson(json)).toList();
      } else {
        print('Error fetching citas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error connection citas: $e');
      return [];
    }
  }

  // 2. Obtener Recomendadas (Automático)
  Future<List<VeterinariaRecomendada>> getVeterinariasRecomendadas() async {
    final userId = await _getUserId();
    if (userId.isEmpty) return [];

    final url = Uri.parse('${Environment.baseUrl}/veterinarias/recomendadas/$userId');
    
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => VeterinariaRecomendada.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}