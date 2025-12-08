import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart'; 
import '../web/web_layout_screen.dart'; 

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Switch: true = VETERINARIO, false = CLIENTE
  bool _isVeterinario = false; 

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Icon(Icons.pets, size: 50, color: AppColors.primary400),
                    const SizedBox(height: 10),
                    Text("PetVida", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary400, fontSize: 32)),
                    const SizedBox(height: 30),

                    // Inputs
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Nombre Completo"),
                      validator: (v) => v!.isEmpty ? "Falta nombre" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Correo"),
                      validator: (v) => !v!.contains('@') ? "Correo inválido" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Contraseña (Mín 8)"),
                      // VALIDACIÓN CRÍTICA: Debe coincidir con el backend (min 8)
                      validator: (v) => (v == null || v.length < 8) ? "Mínimo 8 caracteres" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Confirmar Contraseña"),
                      validator: (v) => v != _passwordController.text ? "No coinciden" : null,
                    ),
                    const SizedBox(height: 16),

                    // SWITCH DE ROL
                    SwitchListTile(
                      title: const Text("Soy Dueño de Veterinaria"),
                      subtitle: const Text("Activa esto para crear cuenta de VETERINARIO"),
                      value: _isVeterinario,
                      activeColor: AppColors.primary400,
                      onChanged: (val) {
                        setState(() => _isVeterinario = val);
                        print("DEBUG: Switch cambiado a: $_isVeterinario");
                      },
                    ),

                    const SizedBox(height: 24),

                    // Error UI
                    if (authProvider.errorMessage != null)
                      Text(authProvider.errorMessage!, style: const TextStyle(color: AppColors.error)),

                    // BOTÓN REGISTRAR
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                print("DEBUG: Botón presionado");

                                if (_formKey.currentState!.validate()) {
                                  print("DEBUG: Formulario válido. Enviando datos...");
                                  print("DEBUG: Rol seleccionado: ${_isVeterinario ? 'VETERINARIO' : 'CLIENTE'}");

                                  final success = await authProvider.register(
                                    _nameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                    _isVeterinario, // <--- Aquí pasamos el booleano
                                  );

                                  print("DEBUG: Resultado del registro: $success");

                                  if (success && context.mounted) {
                                    // Redirección
                                    Widget nextScreen = _isVeterinario 
                                        ? const WebLayoutScreen() // Dashboard para Vets
                                        : const MainScreen();     // App para Clientes

                                    print("DEBUG: Navegando a ${nextScreen.toString()}");
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => nextScreen),
                                      (route) => false,
                                    );
                                  }
                                } else {
                                  print("DEBUG: Formulario INVÁLIDO (Revisar campos en rojo)");
                                }
                              },
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Registrarse"),
                      ),
                    ),
                    
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Volver al Login"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}