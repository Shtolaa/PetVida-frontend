// Modelo para las citas próximas
// Adaptado al AppointmentResponseDTO.java del backend
class CitaAgendada {
  final int idCita;
  final String titulo;      // Lo armaremos combinando Fecha + Hora
  final String subtitulo;   // Lo armaremos combinando Mascota + Veterinaria
  final String estado;
  final DateTime fecha;

  CitaAgendada({
    required this.idCita,
    required this.titulo,
    required this.subtitulo,
    required this.estado,
    required this.fecha,
  });

  factory CitaAgendada.fromJson(Map<String, dynamic> json) {
    // 1. Extraer datos planos del DTO de Java
    // El backend envía: "fecha": "2025-12-06", "hora": "14:00"
    final String fechaStr = json['fecha']?.toString() ?? '';
    final String horaStr = json['hora']?.toString() ?? '';
    
    // El backend envía: "nombreMascota", "nombreVeterinaria"
    final String nombreMascota = json['nombreMascota'] ?? 'Mascota';
    final String nombreVeterinaria = json['nombreVeterinaria'] ?? 'Veterinaria';
    final String nombreServicio = json['nombreServicio'] ?? 'Servicio';

    // 2. Construir los textos para la UI
    // Titulo: "2025-12-06 - 14:00"
    final String tituloGenerado = "$fechaStr - $horaStr";
    
    // Subtitulo: "Luna - Clínica UfroPet (Vacuna)"
    final String subtituloGenerado = "$nombreMascota - $nombreVeterinaria ($nombreServicio)";

    return CitaAgendada(
      // OJO: En Java el campo es 'id', en Flutter lo llamamos 'idCita'
      idCita: json['id'] ?? 0, 
      titulo: tituloGenerado,
      subtitulo: subtituloGenerado,
      estado: json['estado'] ?? 'PENDIENTE',
      fecha: DateTime.tryParse('$fechaStr $horaStr') ?? DateTime.now(),
    );
  }
}

// Modelo para veterinarias recomendadas
// Adaptado a que el backend devuelve la Entidad Veterinary directa
class VeterinariaRecomendada {
  final int id;
  final String nombre;
  final String imagenUrl;
  final double calificacion;

  VeterinariaRecomendada({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.calificacion,
  });

  factory VeterinariaRecomendada.fromJson(Map<String, dynamic> json) {
    return VeterinariaRecomendada(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin Nombre',
      // Validación extra para evitar errores si la URL viene nula
      imagenUrl: json['imagenUrl'] ?? '', 
      calificacion: (json['calificacion'] ?? 0).toDouble(),
    );
  }
}