import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../models/profile_models.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../widgets/pet_avatar.dart'; // Para MascotaResumen

class EditPetScreen extends StatefulWidget {
  final MascotaResumen mascota; // Recibimos la mascota a editar

  const EditPetScreen({super.key, required this.mascota});

  @override
  State<EditPetScreen> createState() => _EditPetScreenState();
}

class _EditPetScreenState extends State<EditPetScreen> {
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController(); // No viene en el resumen, placeholder
  final _fechaController = TextEditingController(); // Placeholder
  final List<String> _especiesPermitidas = ["Canino", "Felino", "Ave", "Exotico"];

  String _especieSeleccionada = 'Canino';
  String _generoSeleccionado = 'Macho';
  File? _imagenNueva;

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() => _imagenNueva = File(pickedFile.path));
    }
  }

  @override
  void initState() {
    super.initState();
    // Llenar datos (Lo que tengamos disponible en MascotaResumen)
    _nombreController.text = widget.mascota.nombre;
  
    String especieEntrante = widget.mascota.especie;
    // Como MascotaResumen es limitado, los otros campos quedarán vacíos o default
    // Idealmente deberíamos llamar a un GET /mascotas/{id} para tener todo el detalle antes de editar

    if (especieEntrante == "Perro") especieEntrante = "Canino";
    if (especieEntrante == "Gato") especieEntrante = "Felino";

    // Verificación final de seguridad:
    if (_especiesPermitidas.contains(especieEntrante)) {
      _especieSeleccionada = especieEntrante;
    } else {
      // Si llega algo raro (ej: "Lagarto"), usamos el primero por defecto para no crashear
      _especieSeleccionada = _especiesPermitidas.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor Mascota"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar", style: TextStyle(color: AppColors.primary400)))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Foto Mascota
            Center(
                child: GestureDetector(
                  onTap: _seleccionarFoto,
                  child: Stack(
                    children: [
                      // Usamos nuestro widget inteligente
                      PetAvatar(
                        radius: 50,
                        // Si hay foto nueva, la muestra. Si no, muestra la que viene del backend
                        imageFile: _imagenNueva,
                        imageString: widget.mascota.fotoUrl, 
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
                          child: const Icon(Icons.edit, color: Colors.white, size: 20),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre de la mascota"),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _especieSeleccionada,
              decoration: const InputDecoration(labelText: "Especie"),
              items: const [
                DropdownMenuItem(value: "Canino", child: Text("Perro")),
                DropdownMenuItem(value: "Felino", child: Text("Gato")),
                DropdownMenuItem(value: "Ave", child: Text("Ave")),
                DropdownMenuItem(value: "Exotico", child: Text("Exótico")),
              ],
              onChanged: (val) => setState(() => _especieSeleccionada = val!),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _razaController,
              decoration: const InputDecoration(labelText: "Raza"),
            ),
            const SizedBox(height: 16),

            // Género (Botones)
            Row(
              children: [
                Expanded(child: _buildGenderBtn("Macho")),
                const SizedBox(width: 16),
                Expanded(child: _buildGenderBtn("Hembra")),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: provider.isLoading ? null : () async {
                      final success = await provider.actualizarMascota(
                        widget.mascota.id,
                        _nombreController.text,
                        _especieSeleccionada,
                        _razaController.text,
                        _generoSeleccionado,
                        "2020-01-01", // O usa un controller de fecha real
                        _imagenNueva, // <--- Enviamos la foto nueva (o null si no cambió)
                      );
                  
                  if (success && mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mascota modificada")));
                  } else if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error (Probablemente falta endpoint PUT)"), backgroundColor: AppColors.warning));
                  }
                },
                child: const Text("Guardar"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGenderBtn(String genero) {
    final isSelected = _generoSeleccionado == genero;
    return GestureDetector(
      onTap: () => setState(() => _generoSeleccionado = genero),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary200 : Colors.white,
          border: Border.all(color: isSelected ? AppColors.primary400 : AppColors.neutral300),
          borderRadius: BorderRadius.circular(20)
        ),
        alignment: Alignment.center,
        child: Text(genero, style: TextStyle(
          color: isSelected ? AppColors.primary500 : AppColors.neutral500,
          fontWeight: FontWeight.bold
        )),
      ),
    );
  }
}