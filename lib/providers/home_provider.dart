import 'package:flutter/material.dart';
import '../models/home_models.dart';
import '../services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService = HomeService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<CitaAgendada> _citas = [];
  List<CitaAgendada> get citas => _citas;

  List<VeterinariaRecomendada> _recomendadas = [];
  List<VeterinariaRecomendada> get recomendadas => _recomendadas;

  // Método para cargar todo al iniciar la pantalla
  Future<void> cargarDatosHome() async {
    _isLoading = true;
    notifyListeners();

    // Hacemos las dos peticiones en paralelo para ganar velocidad
    final resultados = await Future.wait([
      _homeService.getProximasCitas(),
      _homeService.getVeterinariasRecomendadas(),
    ]);

    _citas = resultados[0] as List<CitaAgendada>;
    _recomendadas = resultados[1] as List<VeterinariaRecomendada>;

    _isLoading = false;
    notifyListeners();
  }
}