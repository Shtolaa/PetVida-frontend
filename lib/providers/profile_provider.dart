import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _service = ProfileService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  UsuarioPerfil? _usuario;
  UsuarioPerfil? get usuario => _usuario;

  Future<void> cargarPerfil() async {
    _isLoading = true;
    notifyListeners();

    _usuario = await _service.getUserProfile();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> cerrarSesion() async {
    await _service.logout();
    // No notificamos listeners porque la UI navegará fuera inmediatamente
  }
  Future<bool> registrarMascota(String nombre, String especie, String raza, String genero, String fechaNacimiento) async {
    _isLoading = true;
    notifyListeners();

    final datos = {
      "nombre": nombre,
      "especie": especie, // "Canino" o "Felino" según tu backend
      "raza": raza,
      "genero": genero,
      "fechaNacimiento": fechaNacimiento,
      "foto": "", // Placeholder base64 o URL vacía por ahora
    };

    final exito = await _service.createMascota(datos);

    if (exito) {
      // Si se creó bien, recargamos el perfil para que aparezca en la lista
      await cargarPerfil();
    } else {
      _isLoading = false;
      notifyListeners();
    }
    
    return exito;
  }
}