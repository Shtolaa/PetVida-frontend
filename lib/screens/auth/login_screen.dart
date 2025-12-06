import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para capturar el texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Definimos un degradado suave para el fondo similar al diseño
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  
                  // 1. Logo y Título
                  Icon(Icons.pets, size: 60, color: AppColors.primary400),
                  const SizedBox(height: 16),
                  Text(
                    "PetVida",
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primary400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Bienvenido de nuevo",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),

                  // 2. Campo Email
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Correo", style: Theme.of(context).textTheme.labelLarge),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "ejemplo@correo.com",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa tu correo';
                      if (!value.contains('@')) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // 3. Campo Contraseña
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Contraseña", style: Theme.of(context).textTheme.labelLarge),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "********",
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: Icon(Icons.visibility_off_outlined), // Pendiente: lógica para mostrar
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                      return null;
                    },
                  ),
                  
                  // 4. Olvidaste contraseña
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(color: AppColors.primary400),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Mensaje de Error (si falla el login)
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                      ),
                    ),

                  // 6. Botón de Iniciar Sesión
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                // Ocultar teclado
                                FocusScope.of(context).unfocus();
                                
                                final success = await authProvider.login(
                                  _emailController.text,
                                  _passwordController.text,
                                );

                                if (success && context.mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainScreen()),
                                    (route) => false,
                                  );
                                }
                              }
                            },
                      child: authProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Iniciar Sesión"),
                    ),
                  ),

                  const SizedBox(height: 30),
                  
                  // 7. Registro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes cuenta?"),
                      TextButton(
                        onPressed: () {
                          // TODO: Navegar a Registro
                        },
                        child: const Text(
                          "Regístrate",
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
    );
  }
}