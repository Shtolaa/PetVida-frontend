import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status; // "CONFIRMADA", "PENDIENTE", "CANCELADA"

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String text;

    // Lógica de colores según el estado que venga del backend
    switch (status.toUpperCase()) {
      case 'CONFIRMADA':
      case 'AGENDADA': // Por si el backend usa este término
        bgColor = const Color(0xFFD1F2EB); // Verde suave
        textColor = const Color(0xFF117A65); // Verde oscuro
        text = "Confirmada";
        break;
      case 'PENDIENTE':
      case 'ESPERANDO_CONFIRMACION':
        bgColor = const Color(0xFFE8DAEF); // Morado suave
        textColor = const Color(0xFF6C3483); // Morado oscuro
        text = "Esperando Confirmación";
        break;
      case 'CANCELADA':
        bgColor = const Color(0xFFFADBD8); // Rojo suave
        textColor = const Color(0xFFC0392B); // Rojo oscuro
        text = "Cancelada";
        break;
      default:
        bgColor = AppColors.neutral200;
        textColor = AppColors.neutral500;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}