import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/web_dashboard_models.dart';
import '../config/constants/environment.dart';

class WebDashboardService {
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // GET /veterinarias/{id}/dashboard
  Future<DashboardResponse?> getDashboardMetrics(int idVeterinaria) async {
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$idVeterinaria/dashboard');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return DashboardResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Error Dashboard KPIs: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error conexión Dashboard: $e');
      return null;
    }
  }

  // GET /veterinarias/{id}/citas (Tabla)
  Future<List<CitaVeterinaria>> getCitasVeterinaria(int idVeterinaria) async {
    // Podrías agregar ?page=0&size=10 aquí si quisieras paginar
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$idVeterinaria/citas');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CitaVeterinaria.fromJson(json)).toList();
      } else {
        print('Error Tabla Citas: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error conexión Tabla: $e');
      return [];
    }
  }
}