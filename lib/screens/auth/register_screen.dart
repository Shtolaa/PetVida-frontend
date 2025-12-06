import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart'; // Para ir al Home móvil
import '../web/web_layout_screen.dart'; // Para ir al Dashboard web

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Opción para veterinarios (Tu idea)
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
            colors: [
              AppColors.primary100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Encabezado
                    const Icon(Icons.pets, size: 50, color: AppColors.primary400),
                    const SizedBox(height: 10),
                    Text("PetVida", style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.primary400, fontSize: 32)),
                    const SizedBox(height: 8),
                    Text("Crea una cuenta nueva", style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 30),

                    // 2. Nombre Completo
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Nombre Completo",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) => value!.isEmpty ? "Ingresa tu nombre" : null,
                    ),
                    const SizedBox(height: 16),

                    // 3. Correo
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Correo Electrónico",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Ingresa tu correo';
                        if (!value.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 4. Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. Confirmar Contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirmar Contraseña",
                        prefixIcon: Icon(Icons.lock_reset),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 6. Opción "Soy Veterinario" (Tu idea implementada)
                    SwitchListTile(
                      title: const Text("Soy Dueño de Veterinaria"),
                      subtitle: const Text("Crea una cuenta para gestionar tu clínica"),
                      value: _isVeterinario,
                      activeColor: AppColors.primary400,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() => _isVeterinario = val);
                      },
                    ),

                    const SizedBox(height: 24),

                    // 7. Mensaje de Error
                    if (authProvider.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // 8. Botón Registrarse
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                if (_formKey.currentState!.validate()) {
                                  final success = await authProvider.register(
                                    _nameController.text,
                                    _emailController.text,
                                    _passwordController.text,
                                    _isVeterinario,
                                  );

                                  if (success && context.mounted) {
                                    // Redirección inteligente según el rol elegido
                                    Widget nextScreen = _isVeterinario 
                                        ? const WebLayoutScreen() 
                                        : const MainScreen();

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (_) => nextScreen),
                                      (route) => false,
                                    );
                                  }
                                }
                              },
                        child: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Registrarse"),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 9. Volver al Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("¿Ya tienes cuenta?"),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Inicia Sesión",
                            style: TextStyle(color: AppColors.primary400, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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