import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Avisa a la pantalla que actualice (muestre loading)

    final success = await _authService.login(email, password);

    _isLoading = false;
    
    if (!success) {
      _errorMessage = "Correo o contraseña incorrectos";
    }
    
    notifyListeners(); // Avisa que terminó
    return success;
  }
  Future<String> getUserRole() async {
  return await _authService.getUserRole();
}
}