import 'package:flutter/foundation.dart'; // Necesario para kIsWeb

class Environment {
  // Getter inteligente: detecta la plataforma
  static String get baseUrl {
    if (kIsWeb) {
      // Si estamos en Chrome/Web, usamos localhost
      return 'http://localhost:8080/api/v1';
    } else {
      // Si estamos en Android Emulator, usamos 10.0.2.2
      // (Si usaras un celular físico por USB, aquí iría tu IP de red local ej: 192.168.1.X)
      return 'http://10.0.2.2:8080/api/v1';
    }
  }
}