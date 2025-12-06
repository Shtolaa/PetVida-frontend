import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); // Decorativo por ahora

  @override
  void initState() {
    super.initState();
    // Pre-llenamos los datos actuales
    final user = Provider.of<ProfileProvider>(context, listen: false).usuario;
    if (user != null) {
      _nameController.text = user.nombreCompleto;
      _emailController.text = user.email;
      _phoneController.text = "+56 9 1234 5678"; // Placeholder
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar Cuenta"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto Circular
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.neutral200,
              backgroundImage: NetworkImage("https://via.placeholder.com/150"), // Tu foto real iría aquí
              child: Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary400,
                  child: Icon(Icons.camera_alt, size: 16, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(provider.usuario?.nombreCompleto ?? "Usuario", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            
            const SizedBox(height: 40),

            _buildLabel("Nombre Completo"),
            TextFormField(controller: _nameController),
            const SizedBox(height: 20),

            _buildLabel("Correo"),
            TextFormField(controller: _emailController),
            const SizedBox(height: 20),

            _buildLabel("Teléfono"),
            TextFormField(controller: _phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 40),

            // Botones
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error, 
                      foregroundColor: Colors.white
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () async {
                      final success = await provider.actualizarPerfilUsuario(
                        _nameController.text,
                        _emailController.text,
                      );
                      if (success && mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
                      }
                    },
                    child: provider.isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Confirmar"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral500)),
      ),
    );
  }
}