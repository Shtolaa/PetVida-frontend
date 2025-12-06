import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_models.dart';
import '../config/constants/environment.dart';

class BookingService {
  
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }
  
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id') ?? '';
  }

  // 1. Obtener Horarios Disponibles
  Future<DisponibilidadResponse?> getHorarios(int vetId, String fecha) async {
    // endpoint: /veterinarias/{id}/horarios?fecha=YYYY-MM-DD
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$vetId/horarios?fecha=$fecha');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return DisponibilidadResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Error horarios: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error conexión horarios: $e');
      return null;
    }
  }

  // 2. Crear Cita
  Future<bool> crearCita(CrearCitaRequest reserva) async {
    final url = Uri.parse('${Environment.baseUrl}/citas');

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(reserva.toJson()),
      );

      // 201 Created es lo ideal, 200 OK también sirve
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error booking: ${response.body}');
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}