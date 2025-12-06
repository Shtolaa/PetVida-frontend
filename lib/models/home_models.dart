
class CitaAgendada {
  final int idCita;
  final String titulo;      // Ej: "Lunes 28/10 - 18:00"
  final String subtitulo;   // Ej: "Luna - Clínica Vet..."
  final String estado;      // Ej: "AGENDADA"
  final DateTime fecha;     

  CitaAgendada({
    required this.idCita,
    required this.titulo,
    required this.subtitulo,
    required this.estado,
    required this.fecha,
  });

  factory CitaAgendada.fromJson(Map<String, dynamic> json) {
    final datos = json['datosEstructurados'] ?? {};
    return CitaAgendada(
      idCita: json['idCita'] ?? 0,
      titulo: json['titulo'] ?? '',
      subtitulo: json['subtitulo'] ?? '',
      estado: json['estado'] ?? 'PENDIENTE',
      // Parseamos la fecha o usamos la actual si viene nula
      fecha: datos['fecha'] != null 
          ? DateTime.parse('${datos['fecha']} ${datos['hora']}') 
          : DateTime.now(),
    );
  }
}

// Modelo para veterinarias recomendadas
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
      nombre: json['nombre'] ?? 'Veterinaria',
      imagenUrl: json['imagenUrl'] ?? '',
      calificacion: (json['calificacion'] ?? 0).toDouble(),
    );
  }
}