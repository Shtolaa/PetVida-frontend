import 'dart:async'; // Para el Debounce
import 'package:flutter/material.dart';
import '../models/vet_model.dart';
import '../services/vet_service.dart';

class VetProvider extends ChangeNotifier {
  final VetService _service = VetService();

  List<Veterinaria> _veterinarias = [];
  List<Veterinaria> get veterinarias => _veterinarias;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Filtros actuales
  String _busquedaActual = '';
  bool _soloAbierto = false;
  
  // Timer para no buscar en cada tecla (Debounce)
  Timer? _debounce;

  bool get soloAbierto => _soloAbierto;

  // Carga inicial
  Future<void> cargarVeterinarias() async {
    _isLoading = true;
    notifyListeners();

    _veterinarias = await _service.getVeterinarias(
      busqueda: _busquedaActual,
      soloAbierto: _soloAbierto,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Método para cuando el usuario escribe en el buscador
  void onSearchChanged(String query) {
    _busquedaActual = query;
    
    // Si el usuario deja de escribir por 500ms, buscamos
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      cargarVeterinarias();
    });
  }

  // Método para activar/desactivar filtro "Abierto"
  void toggleAbierto() {
    _soloAbierto = !_soloAbierto;
    cargarVeterinarias(); // Recargamos inmediato
    // No necesitamos notifyListeners aquí porque cargarVeterinarias ya lo hace
  }
}