import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; 
import '../../config/theme/app_theme.dart';
import '../../providers/profile_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _fechaController = TextEditingController(); // Solo para mostrar texto
  
  String _especieSeleccionada = 'Canino';
  String _generoSeleccionado = 'Macho';
  String _fechaBackend = ''; // Formato YYYY-MM-DD para enviar

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Mascota"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Foto Placeholder (Círculo con ícono)
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.neutral200,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.neutral300),
                      ),
                      child: const Icon(Icons.pets, size: 50, color: AppColors.neutral500),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary400,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 2. Nombre
              Text("Nombre de la mascota", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(hintText: "Ej: Luna"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

              // 3. Especie
              Text("Especie", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _especieSeleccionada,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: "Canino", child: Text("Perro")),
                  DropdownMenuItem(value: "Felino", child: Text("Gato")),
                  DropdownMenuItem(value: "Exotico", child: Text("Exótico")),
                ],
                onChanged: (val) => setState(() => _especieSeleccionada = val!),
              ),
              const SizedBox(height: 20),

              // 4. Raza
              Text("Raza", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(hintText: "Ej: Golden Retriever"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

              // 5. Género
              Text("Género", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _buildGenderOption("Macho")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGenderOption("Hembra")),
                ],
              ),
              const SizedBox(height: 20),

              // 6. Fecha de Nacimiento
              Text("Fecha de nacimiento", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fechaController,
                readOnly: true, // No se puede escribir, solo tocar
                decoration: const InputDecoration(
                  hintText: "Seleccionar fecha",
                  suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary400),
                ),
                onTap: _seleccionarFecha,
                validator: (value) => value!.isEmpty ? "Selecciona una fecha" : null,
              ),

              const SizedBox(height: 40),

              // 7. Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: profileProvider.isLoading 
                        ? null 
                        : _guardarMascota,
                      child: profileProvider.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Guardar"),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Widget para botones de género tipo "Píldora"
  Widget _buildGenderOption(String genero) {
    final isSelected = _generoSeleccionado == genero;
    return GestureDetector(
      onTap: () => setState(() => _generoSeleccionado = genero),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary400 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary400 : AppColors.neutral200,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          genero,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutral500,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Lógica del DatePicker
  Future<void> _seleccionarFecha() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.theme.copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary400),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Formato para mostrar al usuario: 10/12/2023
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
        // Formato para el backend: 2023-12-10
        _fechaBackend = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _guardarMascota() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      final exito = await provider.registrarMascota(
        _nombreController.text,
        _especieSeleccionada,
        _razaController.text,
        _generoSeleccionado,
        _fechaBackend,
      );

      if (exito && mounted) {
        Navigator.pop(context); // Volver al perfil
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mascota agregada con éxito"), backgroundColor: AppColors.success),
        );
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al agregar mascota"), backgroundColor: AppColors.error),
        );
      }
    }
  }
}