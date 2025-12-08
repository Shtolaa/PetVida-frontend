import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../services/profile_service.dart';
import 'dart:io';

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
Future<bool> registrarMascota(
      String nombre, 
      String especie, 
      String raza, 
      String genero, 
      String fechaNacimiento, 
      File? imagen // <--- Nuevo parámetro
  ) async {
    _isLoading = true;
    notifyListeners();

    // Ya no enviamos "foto" en el mapa, lo pasamos como argumento aparte
    final datos = {
      "nombre": nombre,
      "especie": especie,
      "raza": raza,
      "genero": genero,
      "fechaNacimiento": fechaNacimiento,
    };

    // Pasamos la imagen al servicio
    final exito = await _service.createMascota(datos, imagen);

    if (exito) {
      await cargarPerfil();
    } else {
      _isLoading = false;
      notifyListeners();
    }
    
    return exito;
  }
  // Método para actualizar Usuario
  Future<bool> actualizarPerfilUsuario(String nombre, String email) async {
    _isLoading = true;
    notifyListeners();

    final exito = await _service.updateProfile(nombre, email);

    if (exito) {
      await cargarPerfil(); // Recargamos para ver los cambios
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return exito;
  }

Future<bool> actualizarMascota(
      int mascotaId, 
      String nombre, 
      String especie, 
      String raza, 
      String genero, 
      String fecha, 
      File? imagen // <--- Nuevo
  ) async {
    _isLoading = true;
    notifyListeners();

    final datos = {
      "nombre": nombre,
      "especie": especie,
      "raza": raza,
      "genero": genero,
      "fechaNacimiento": fecha,
    };

    // Pasamos la imagen al servicio
    final exito = await _service.updateMascota(mascotaId, datos, imagen);

    if (exito) {
      await cargarPerfil();
    } else {
      _isLoading = false;
      notifyListeners();
    }
    return exito;
  }
}