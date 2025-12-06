import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Para formatear fechas si es necesario
import '../../config/theme/app_theme.dart';
import '../../providers/home_provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    // Ejecutamos la carga de datos después de que se construya el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).cargarDatosHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.neutral100, // Fondo gris claro suave
      body: SafeArea(
        child: homeProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: homeProvider.cargarDatosHome,
                color: AppColors.primary400,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER (Nombre del usuario)
                      // TODO: Traer nombre real del usuario
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hola,", style: Theme.of(context).textTheme.bodyLarge),
                              Text(
                                "Nicolás Toledo", // Placeholder
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 20),
                              ),
                            ],
                          ),
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary200,
                            child: Icon(Icons.person, color: AppColors.primary500),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. SECCIÓN RECOMENDADAS (Carrusel)
                      Text(
                        "Veterinarias Recomendadas",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140, // Altura fija para el carrusel
                        child: homeProvider.recomendadas.isEmpty
                            ? const Center(child: Text("No hay recomendaciones aún"))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: homeProvider.recomendadas.length,
                                itemBuilder: (context, index) {
                                  final vet = homeProvider.recomendadas[index];
                                  return Container(
                                    width: 240,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                      image: DecorationImage(
                                        image: NetworkImage(vet.imagenUrl), // Asegúrate que la URL sea válida
                                        fit: BoxFit.cover,
                                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)
                                      )
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 12, left: 12, right: 12,
                                          child: Text(
                                            vet.nombre,
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10, right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                                const SizedBox(width: 4),
                                                Text(vet.calificacion.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 30),

                      // 3. SECCIÓN HORAS RESERVADAS (Lista Vertical)
                      Text(
                        "Horas Reservadas",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      homeProvider.citas.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: const Column(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.neutral300),
                                SizedBox(height: 10),
                                Text("No tienes citas próximas"),
                              ],
                            ),
                          )
                            :ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: homeProvider.citas.length,
                              itemBuilder: (context, index) {
                                final cita = homeProvider.citas[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.neutral200),
                                  ),
                                  child: Row(
                                    children: [
                                      // Fecha (Columna izquierda)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary100.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.access_time_filled, color: AppColors.primary400),
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Datos de la cita
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              cita.titulo, // "Lunes 28/10 - 18:00"
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.neutral1000),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              cita.subtitulo, // "Luna - Clínica..."
                                              style: const TextStyle(color: AppColors.neutral500, fontSize: 14),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // --- NUEVO: Botón Cancelar ---
                                      IconButton(
                                        icon: const Icon(Icons.cancel_outlined, color: AppColors.error),
                                        tooltip: "Cancelar Cita",
                                        onPressed: () {
                                          // Mostramos el Popup de confirmación
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: const Text("Cancelar Cita"),
                                              content: const Text("¿Estás seguro de que deseas cancelar esta hora? Esta acción no se puede deshacer."),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(ctx), // Cerrar sin hacer nada
                                                  child: const Text("Volver"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.pop(ctx); // Cerrar alerta
                                                    
                                                    // Llamar al provider para cancelar
                                                    final exito = await homeProvider.cancelarCita(cita.idCita);
                                                    
                                                    if (context.mounted) {
                                                      if (exito) {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(content: Text("Cita cancelada correctamente"))
                                                        );
                                                      } else {
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            content: Text("Error al cancelar. Intenta más tarde."),
                                                            backgroundColor: AppColors.error,
                                                          )
                                                        );
                                                      }
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                                  child: const Text("Sí, Cancelar"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                      // -----------------------------
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}