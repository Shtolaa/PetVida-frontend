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