class MascotaResumen {
  final int id;
  final String nombre;
  final String especie;
  final String fotoUrl;

  MascotaResumen({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.fotoUrl,
  });

  factory MascotaResumen.fromJson(Map<String, dynamic> json) {
    return MascotaResumen(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      especie: json['especie'] ?? '',
      fotoUrl: json['fotoUrl'] ?? '',
    );
  }
}

class UsuarioPerfil {
  final int id;
  final String nombreCompleto;
  final String email;
  final String fotoPerfilUrl;
  final List<MascotaResumen> mascotas;

  UsuarioPerfil({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.fotoPerfilUrl,
    required this.mascotas,
  });

  factory UsuarioPerfil.fromJson(Map<String, dynamic> json) {
    var listaMascotas = json['mascotas'] as List? ?? [];
    return UsuarioPerfil(
      id: json['id'] ?? 0,
      nombreCompleto: json['nombreCompleto'] ?? 'Usuario',
      email: json['email'] ?? '',
      fotoPerfilUrl: json['fotoPerfilUrl'] ?? '',
      mascotas: listaMascotas.map((m) => MascotaResumen.fromJson(m)).toList(),
    );
  }
}