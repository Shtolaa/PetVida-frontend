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
    Future<DashboardResponse> getDashboardMetrics(int idVeterinaria) async { // Ya no es nullable (?)
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$idVeterinaria/dashboard');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return DashboardResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Backend sin datos (${response.statusCode}), usando Ceros.');
        return _getEmptyDashboard(); // <--- CAMBIO AQUÍ
      }
    } catch (e) {
      print('Error conexión Dashboard: $e. Usando Ceros.');
      return _getEmptyDashboard(); // <--- CAMBIO AQUÍ
    }
  }

Future<List<CitaVeterinaria>> getCitasVeterinaria(int idVeterinaria) async {
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$idVeterinaria/citas');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      // --- DEBUG ---
      print("STATUS CITAS WEB: ${response.statusCode}");
      print("BODY CITAS WEB: ${response.body}");
      // -------------

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
  // 3. Cancelar Cita (Reutilizamos el endpoint que usaste en el móvil)
  Future<bool> cancelarCita(int idCita) async {
    final url = Uri.parse('${Environment.baseUrl}/citas/$idCita/cancelar');

    try {
      final headers = await _getHeaders();
      final response = await http.patch(url, headers: headers);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        print('Error cancelando cita (Web): ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error conexión cancelar (Web): $e');
      return false;
    }
  }
  Future<int?> getMyVeterinaryId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    if (userId == null) return null;

    final url = Uri.parse('${Environment.baseUrl}/veterinarias/usuario/$userId');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id']; // Extraemos solo el ID de la clínica
      }
      return null;
    } catch (e) {
      print("Error obteniendo ID veterinaria: $e");
      return null;
    }
  }
  DashboardResponse _getEmptyDashboard() {
    return DashboardResponse(
      horasAgendadas: KpiItem(valor: 0, tendencia: "NEUTRA", mensajeTendencia: "Sin datos"),
      horasCanceladas: KpiItem(valor: 0, tendencia: "NEUTRA", mensajeTendencia: "Sin datos"),
      interacciones: KpiItem(valor: 0, tendencia: "NEUTRA", mensajeTendencia: "Sin datos"),
      horasHoy: KpiItem(valor: 0, tendencia: "NEUTRA", mensajeTendencia: "Sin datos"),
      tituloGrafico: "Resumen (Sin datos)",
      datosGrafico: [], // Gráfico vacío
    );
  }
  Future<String> getVeterinaryName(int idVeterinaria) async {
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$idVeterinaria');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['nombre'] ?? 'Mi Veterinaria';
      }
    } catch (e) {
      print("Error obteniendo nombre vet: $e");
    }
    return "Mi Veterinaria";
  }
}