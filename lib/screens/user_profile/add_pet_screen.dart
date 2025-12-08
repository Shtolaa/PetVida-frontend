import 'dart:io'; // Para manejar el archivo
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart'; // Librería de imágenes
import '../../config/theme/app_theme.dart';
import '../../providers/profile_provider.dart';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _fechaController = TextEditingController();
  
  String _especieSeleccionada = 'Canino';
  String _generoSeleccionado = 'Macho';
  String _fechaBackend = '';

  // Variable para guardar la foto seleccionada
  File? _imagenSeleccionada;

  // Método para abrir la galería
  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

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
              // 1. SELECCIONAR FOTO
              Center(
                child: GestureDetector(
                  onTap: _seleccionarFoto, // Al tocar abre la galería
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.neutral300),
                          // Si hay imagen seleccionada, la mostramos
                          image: _imagenSeleccionada != null
                              ? DecorationImage(
                                  image: FileImage(_imagenSeleccionada!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        // Si NO hay imagen, mostramos el ícono
                        child: _imagenSeleccionada == null
                            ? const Icon(Icons.pets, size: 50, color: AppColors.neutral500)
                            : null,
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
              ),
              const SizedBox(height: 10),
              Center(child: Text("Toca para subir foto", style: TextStyle(fontSize: 12, color: AppColors.neutral500))),
              const SizedBox(height: 30),

              // ... (El resto de los campos: Nombre, Especie, Raza... Sigue IGUAL) ...
              // Solo copia los inputs que ya tenías aquí abajo
              
              Text("Nombre de la mascota", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(hintText: "Ej: Luna"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

              Text("Especie", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _especieSeleccionada,
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem(value: "Canino", child: Text("Perro")),
                  DropdownMenuItem(value: "Felino", child: Text("Gato")),
                  DropdownMenuItem(value: "Ave", child: Text("Ave")),
                  DropdownMenuItem(value: "Exotico", child: Text("Exótico")),
                ],
                onChanged: (val) => setState(() => _especieSeleccionada = val!),
              ),
              const SizedBox(height: 20),

              Text("Raza", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _razaController,
                decoration: const InputDecoration(hintText: "Ej: Golden Retriever"),
                validator: (value) => value!.isEmpty ? "Campo obligatorio" : null,
              ),
              const SizedBox(height: 20),

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

              Text("Fecha de nacimiento", style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                decoration: const InputDecoration(
                  hintText: "Seleccionar fecha",
                  suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary400),
                ),
                onTap: _seleccionarFecha,
                validator: (value) => value!.isEmpty ? "Selecciona una fecha" : null,
              ),

              const SizedBox(height: 40),

              // Botones
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
                      onPressed: profileProvider.isLoading ? null : _guardarMascota,
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

  // ... (Tus métodos _buildGenderOption y _seleccionarFecha siguen IGUAL) ...
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
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
        _fechaBackend = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _guardarMascota() async {
    if (_formKey.currentState!.validate()) {
      // 1. Obtenemos el provider
      final provider = Provider.of<ProfileProvider>(context, listen: false);
      
      // 2. Llamamos a registrar pasando los datos Y LA IMAGEN
      final exito = await provider.registrarMascota(
        _nombreController.text,
        _especieSeleccionada,
        _razaController.text,
        _generoSeleccionado,
        _fechaBackend,
        _imagenSeleccionada, // <--- Pasamos el archivo aquí
      );

      if (exito && mounted) {
        Navigator.pop(context);
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