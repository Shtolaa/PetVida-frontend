// Modelo para visualizar los bloques de horarios (GET /horarios)
class BloqueHorario {
  final String titulo;   // Ej: "Mañana 07:00 - 12:30"
  final List<String> horarios; // Ej: ["09:00", "09:30", ...]

  BloqueHorario({required this.titulo, required this.horarios});

  factory BloqueHorario.fromJson(Map<String, dynamic> json) {
    return BloqueHorario(
      titulo: json['titulo'] ?? '',
      horarios: List<String>.from(json['horarios'] ?? []),
    );
  }
}

class DisponibilidadResponse {
  final String fechaConsultada;
  final List<BloqueHorario> bloques;

  DisponibilidadResponse({required this.fechaConsultada, required this.bloques});

  factory DisponibilidadResponse.fromJson(Map<String, dynamic> json) {
    var list = json['bloques'] as List? ?? [];
    return DisponibilidadResponse(
      fechaConsultada: json['fechaConsultada'] ?? '',
      bloques: list.map((i) => BloqueHorario.fromJson(i)).toList(),
    );
  }
}

// Modelo para CREAR la cita (POST /citas)
class CrearCitaRequest {
  final int usuarioId;
  final int mascotaId;
  final int veterinariaId;
  final int servicioId;
  final String fecha; // YYYY-MM-DD
  final String hora;  // HH:MM

  CrearCitaRequest({
    required this.usuarioId,
    required this.mascotaId,
    required this.veterinariaId,
    required this.servicioId,
    required this.fecha,
    required this.hora,
  });

  Map<String, dynamic> toJson() {
    return {
      "usuarioId": usuarioId,
      "mascotaId": mascotaId,
      "veterinariaId": veterinariaId,
      "servicioId": servicioId,
      "fecha": fecha,
      "hora": hora,
    };
  }
}