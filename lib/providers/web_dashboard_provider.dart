import 'package:flutter/material.dart';
import '../models/web_dashboard_models.dart';
import '../services/web_dashboard_service.dart';

class WebDashboardProvider extends ChangeNotifier {
  final WebDashboardService _service = WebDashboardService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DashboardResponse? _metrics;
  DashboardResponse? get metrics => _metrics;

  List<CitaVeterinaria> _citas = [];
  List<CitaVeterinaria> get citas => _citas;

  // ID Temporal de la veterinaria (En el futuro esto viene del login)
  final int _currentVetId = 1; 

  Future<void> cargarDashboard() async {
    _isLoading = true;
    notifyListeners();

    // Cargamos ambas cosas en paralelo
    final results = await Future.wait([
      _service.getDashboardMetrics(_currentVetId),
      _service.getCitasVeterinaria(_currentVetId),
    ]);

    _metrics = results[0] as DashboardResponse?;
    _citas = results[1] as List<CitaVeterinaria>;

    _isLoading = false;
    notifyListeners();
  }
  Future<bool> cancelarCita(int idCita) async {
    // 1. Mostramos carga (opcional, o dejamos que el spinner de la tabla actúe al recargar)
    _isLoading = true;
    notifyListeners();

    // 2. Llamada al servicio
    final exito = await _service.cancelarCita(idCita);

    if (exito) {
      // 3. Si funcionó, recargamos los datos del dashboard para refrescar la tabla
      await cargarDashboard(); 
    } else {
      // Si falló, quitamos el loading
      _isLoading = false;
      notifyListeners();
    }
    
    return exito;
  }
}