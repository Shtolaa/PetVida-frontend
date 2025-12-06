import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/booking_models.dart';
import '../services/booking_service.dart';

class BookingProvider extends ChangeNotifier {
  final BookingService _service = BookingService();

  // Estado de la selección
  DateTime _fechaSeleccionada = DateTime.now();
  String? _horaSeleccionada;
  int? _veterinariaId;
  int? _servicioId;
  int? _mascotaId;
  
  // Datos de API
  List<BloqueHorario> _bloques = [];
  bool _isLoading = false;

  // Getters
  DateTime get fechaSeleccionada => _fechaSeleccionada;
  String? get horaSeleccionada => _horaSeleccionada;
  List<BloqueHorario> get bloques => _bloques;
  bool get isLoading => _isLoading;
  int? get mascotaId => _mascotaId;

  // Setters simples
  void setVeterinariaYServicio(int vetId, int servId) {
    _veterinariaId = vetId;
    _servicioId = servId;
    // Al iniciar, cargamos horarios para hoy
    cargarHorarios(DateTime.now());
  }

  void seleccionarMascota(int id) {
    _mascotaId = id;
    notifyListeners();
  }

  void seleccionarHora(String hora) {
    _horaSeleccionada = hora;
    notifyListeners();
  }

  // Lógica de carga
  Future<void> cargarHorarios(DateTime fecha) async {
    _fechaSeleccionada = fecha;
    _horaSeleccionada = null; // Reset hora al cambiar día
    _isLoading = true;
    notifyListeners();

    if (_veterinariaId == null) return;

    final fechaString = DateFormat('yyyy-MM-dd').format(fecha);
    final response = await _service.getHorarios(_veterinariaId!, fechaString);

    if (response != null) {
      _bloques = response.bloques;
    } else {
      _bloques = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Confirmación final
  Future<bool> confirmarReserva() async {
    if (_veterinariaId == null || _servicioId == null || _mascotaId == null || _horaSeleccionada == null) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final userIdString = await _service.getUserId();
    final userId = int.tryParse(userIdString) ?? 0;

    final request = CrearCitaRequest(
      usuarioId: userId,
      mascotaId: _mascotaId!,
      veterinariaId: _veterinariaId!,
      servicioId: _servicioId!,
      fecha: DateFormat('yyyy-MM-dd').format(_fechaSeleccionada),
      hora: _horaSeleccionada!,
    );

    final exito = await _service.crearCita(request);

    _isLoading = false;
    notifyListeners();
    return exito;
  }
}