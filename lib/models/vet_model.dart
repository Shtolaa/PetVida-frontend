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
      // --- CAMBIO CLAVE: Soporte bilingüe (Español o Inglés) ---
      nombre: json['nombre'] ?? json['name'] ?? 'Sin Nombre',
      direccion: json['direccion'] ?? json['address'] ?? 'Sin dirección',
      
      // Calificación: rating (Java) o calificacion (Flutter antiguo)
      calificacion: (json['calificacion'] ?? json['rating'] ?? 0).toDouble(),
      
      // Abierto: isOpen (Java) o estaAbierto (Flutter antiguo)
      estaAbierto: json['estaAbierto'] ?? json['isOpen'] ?? false,
      
      // Imagen: imageUrl (Java) o imagenUrl (Flutter antiguo)
      imagenUrl: json['imagenUrl'] ?? json['imageUrl'] ?? '',
      // ---------------------------------------------------------
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
      nombre: json['nombre'] ?? json['name'] ?? '', // También aquí por si acaso
    );
  }
}

// Clase Detalle
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
    var listServicios = json['servicios'] ?? json['services'] as List? ?? []; // services en Java
    
    return VeterinariaDetalle(
      id: json['id'] ?? 0,
      // --- CAMBIOS TAMBIÉN AQUÍ PARA EL DETALLE ---
      nombre: json['nombre'] ?? json['name'] ?? '',
      descripcion: json['descripcion'] ?? json['description'] ?? '',
      direccion: json['direccion'] ?? json['address'] ?? '',
      // Java llama a esto 'attentionTimeText' según tu entidad, lo agregamos:
      horarioAtencion: json['horarioAtencion'] ?? json['attentionTimeText'] ?? '',
      
      calificacion: (json['calificacion'] ?? json['rating'] ?? 0).toDouble(),
      imagenUrl: json['imagenUrl'] ?? json['imageUrl'] ?? '',
      
      servicios: (listServicios as List).map((s) => ServicioVet.fromJson(s)).toList(),
    );
  }
}