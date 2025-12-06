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
    final url = Uri.parse('${Environment.baseUrl}/veterinarias/$vetId/horarios?fecha=$fecha');

    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        // 1. Decodificamos como LISTA (porque el back envía ["09:00", "09:30"])
        List<dynamic> listaPlana = jsonDecode(response.body);
        
        // 2. Convertimos a Strings y limpiamos segundos si vienen (09:00:00 -> 09:00)
        List<String> horarios = listaPlana.map((e) {
          String h = e.toString();
          if (h.length > 5) return h.substring(0, 5); // Cortamos los segundos
          return h;
        }).toList();

        // 3. Separamos manualmente en Mañana (< 13:00) y Tarde (>= 13:00)
        List<String> manana = [];
        List<String> tarde = [];

        for (var hora in horarios) {
          int h = int.parse(hora.split(':')[0]);
          if (h < 13) {
            manana.add(hora);
          } else {
            tarde.add(hora);
          }
        }

        // 4. Construimos la respuesta que la UI espera
        List<BloqueHorario> bloquesGenerados = [];
        
        if (manana.isNotEmpty) {
          bloquesGenerados.add(BloqueHorario(titulo: "Mañana", horarios: manana));
        }
        if (tarde.isNotEmpty) {
          bloquesGenerados.add(BloqueHorario(titulo: "Tarde", horarios: tarde));
        }
        
        // Si ambos están vacíos, mandamos lista vacía
        if (bloquesGenerados.isEmpty && horarios.isEmpty) {
           // Fallback visual si la lista viene vacía
           return DisponibilidadResponse(fechaConsultada: fecha, bloques: []);
        }

        return DisponibilidadResponse(
          fechaConsultada: fecha,
          bloques: bloquesGenerados
        );

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