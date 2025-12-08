import 'dart:convert'; // Para base64Decode
import 'dart:io';
import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';

class PetAvatar extends StatelessWidget {
  final String? imageString; // Puede ser Base64 o URL del backend
  final File? imageFile;     // Foto nueva seleccionada del celular
  final double radius;

  const PetAvatar({
    super.key,
    this.imageString,
    this.imageFile,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;

    // 1. Prioridad: Archivo local (Si el usuario eligió una foto nueva)
    if (imageFile != null) {
      provider = FileImage(imageFile!);
    } 
    // 2. Si viene texto del backend
    else if (imageString != null && imageString!.isNotEmpty) {
      // ¿Es una URL web?
      if (imageString!.startsWith('http')) {
        provider = NetworkImage(imageString!);
      } 
      // Asumimos que es Base64 (El backend guarda así)
      else {
        try {
          // Limpiamos cabeceras si vienen (data:image/png;base64,...)
          final cleanBase64 = imageString!.contains(',') 
              ? imageString!.split(',').last 
              : imageString!;
          provider = MemoryImage(base64Decode(cleanBase64));
        } catch (e) {
          print("Error decodificando imagen: $e");
          provider = null;
        }
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.neutral200,
      backgroundImage: provider,
      child: provider == null
          ? Icon(Icons.pets, size: radius * 1.2, color: AppColors.neutral500)
          : null,
    );
  }
}