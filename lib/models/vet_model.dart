class Veterinaria {
  final int id;
  final String nombre;
  final String direccion;
  final double calificacion;
  final bool estaAbierto;
  final String imagenUrl;

  Veterinaria({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.calificacion,
    required this.estaAbierto,
    required this.imagenUrl,
  });

  factory Veterinaria.fromJson(Map<String, dynamic> json) {
    return Veterinaria(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? 'Sin Nombre',
      direccion: json['direccion'] ?? 'Sin dirección',
      // Convertimos a double de forma segura (por si viene int)
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      estaAbierto: json['estaAbierto'] ?? false,
      imagenUrl: json['imagenUrl'] ?? '',
    );
  }
  
}
// Clase para los servicios que ofrece la veterinaria
class ServicioVet {
  final int id;
  final String nombre;

  ServicioVet({required this.id, required this.nombre});

  factory ServicioVet.fromJson(Map<String, dynamic> json) {
    return ServicioVet(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
    );
  }
}

// Clase Detalle (Hereda lo básico o lo definimos completo)
// Para simplificar el mapeo, lo definimos completo según el JSON de respuesta
class VeterinariaDetalle {
  final int id;
  final String nombre;
  final String descripcion;
  final String direccion;
  final String horarioAtencion;
  final double calificacion;
  final String imagenUrl;
  final List<ServicioVet> servicios;

  VeterinariaDetalle({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.direccion,
    required this.horarioAtencion,
    required this.calificacion,
    required this.imagenUrl,
    required this.servicios,
  });

  factory VeterinariaDetalle.fromJson(Map<String, dynamic> json) {
    var listServicios = json['servicios'] as List? ?? [];
    return VeterinariaDetalle(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      direccion: json['direccion'] ?? '',
      horarioAtencion: json['horarioAtencion'] ?? '',
      calificacion: (json['calificacion'] ?? 0).toDouble(),
      imagenUrl: json['imagenUrl'] ?? '',
      servicios: listServicios.map((s) => ServicioVet.fromJson(s)).toList(),
    );
  }
}