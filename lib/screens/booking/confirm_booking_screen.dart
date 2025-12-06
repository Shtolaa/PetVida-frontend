import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import '../../providers/profile_provider.dart';
import '../main_screen.dart';
import '../user_profile/add_pet_screen.dart';

class ConfirmBookingScreen extends StatefulWidget {
  final String nombreVeterinaria;
  final String nombreServicio;

  const ConfirmBookingScreen({
    super.key,
    required this.nombreVeterinaria,
    required this.nombreServicio,
  });

  @override
  State<ConfirmBookingScreen> createState() => _ConfirmBookingScreenState();
}

class _ConfirmBookingScreenState extends State<ConfirmBookingScreen> {
  @override
  void initState() {
    super.initState();
    // Aseguramos que las mascotas estén cargadas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = Provider.of<ProfileProvider>(context, listen: false);
      if (profile.usuario == null) {
        profile.cargarPerfil();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    
    // Formateo de fecha para mostrar bonito (ej: "Lunes 10 de Diciembre")
    final fechaBonita = DateFormat('EEEE d ' 'MMM', 'es').format(bookingProvider.fechaSeleccionada);

    return Scaffold(
      appBar: AppBar(title: const Text("Confirmar Hora")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER: Datos de la Cita
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary100,
                    backgroundImage: const NetworkImage("https://via.placeholder.com/150"), // Placeholder o imagen real si la pasamos
                    child: const Icon(Icons.pets, size: 40, color: AppColors.primary400),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.nombreVeterinaria, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                  Text(widget.nombreServicio, style: const TextStyle(color: AppColors.neutral500, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "$fechaBonita - ${bookingProvider.horaSeleccionada}",
                      style: const TextStyle(color: AppColors.primary500, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 2. SELECCIÓN DE MASCOTA
            Text("¿Quién es el paciente?", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
            const SizedBox(height: 12),

            if (profileProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (profileProvider.usuario?.mascotas.isEmpty ?? true)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: AppColors.error),
                    SizedBox(width: 12),
                    Expanded(child: Text("Debes registrar una mascota en tu perfil antes de agendar.")),
                  ],
                ),
              )
            else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    // Sumamos 1 al total para tener espacio para el botón de "Agregar"
                    itemCount: profileProvider.usuario!.mascotas.length + 1,
                    itemBuilder: (context, index) {
                      
                      // CASO A: Botón "Agregar Nueva Mascota" (Es el último ítem)
                      if (index == profileProvider.usuario!.mascotas.length) {
                        return GestureDetector(
                          onTap: () async {
                            // 1. Navegamos a la pantalla de crear
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddPetScreen()),
                            );
                            
                            // 2. Al volver, recargamos el perfil para que aparezca la nueva mascota en la lista
                            // (Aunque AddPetScreen ya llama a cargarPerfil, esto asegura que la vista se actualice)
                            if (context.mounted) {
                              profileProvider.cargarPerfil();
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.primary400, // Borde verde
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, color: AppColors.primary400),
                                SizedBox(width: 8),
                                Text(
                                  "Agregar nueva mascota",
                                  style: TextStyle(
                                    color: AppColors.primary400,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // CASO B: Tarjeta de Mascota existente (Lógica normal)
                      final mascota = profileProvider.usuario!.mascotas[index];
                      final isSelected = bookingProvider.mascotaId == mascota.id;

                      return GestureDetector(
                        onTap: () => bookingProvider.seleccionarMascota(mascota.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary100.withOpacity(0.3) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.primary400 : AppColors.neutral200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.neutral200,
                                backgroundImage: (mascota.fotoUrl.isNotEmpty) ? NetworkImage(mascota.fotoUrl) : null,
                                child: (mascota.fotoUrl.isEmpty) ? const Icon(Icons.pets, size: 20, color: AppColors.neutral500) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(mascota.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(mascota.especie, style: const TextStyle(fontSize: 12, color: AppColors.neutral500)),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primary400),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            const SizedBox(height: 40),

            // 3. BOTONES DE ACCIÓN
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text("Cancelar"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (bookingProvider.mascotaId == null || bookingProvider.isLoading)
                        ? null // Desactivado si no hay mascota seleccionada
                        : () async {
                            final exito = await bookingProvider.confirmarReserva();
                            
                            if (context.mounted) {
                              if (exito) {
                                // ÉXITO: Diálogo y volver al Home
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (ctx) => AlertDialog(
                                    title: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
                                    content: const Text(
                                      "¡Reserva Confirmada!", 
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(builder: (_) => const MainScreen()),
                                            (route) => false,
                                          );
                                        },
                                        child: const Text("Ir al Inicio"),
                                      )
                                    ],
                                  ),
                                );
                              } else {
                                // ERROR
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Error al agendar. Intenta nuevamente."),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: bookingProvider.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
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
}