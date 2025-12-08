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

  Future<bool> register(String fullName, String email, String password, bool isVeterinario) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Determinamos el rol según el switch
    String role = isVeterinario ? "VETERINARIO" : "CLIENTE"; 

    final success = await _authService.register(fullName, email, password, role);

    _isLoading = false;
    
    if (!success) {
      _errorMessage = "No se pudo registrar. El correo podría estar en uso.";
    }
    
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    // Llamamos al servicio de autenticación para borrar datos
    await _authService.logout();
    
    // Opcional: También podemos limpiar SharedPreferences completamente aquí para estar seguros
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.clear();
    
    notifyListeners();
  }
}