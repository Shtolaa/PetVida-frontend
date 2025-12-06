import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/vet_provider.dart';
import '../booking/availability_screen.dart';

class VetProfileScreen extends StatefulWidget {
  final int veterinariaId;
  final String nombrePlaceholder; // Para mostrar en la AppBar mientras carga

  const VetProfileScreen({
    super.key, 
    required this.veterinariaId,
    required this.nombrePlaceholder
  });

  @override
  State<VetProfileScreen> createState() => _VetProfileScreenState();
}

class _VetProfileScreenState extends State<VetProfileScreen> {

  int? _servicioSeleccionadoId; 
  String _nombreServicioSeleccionado = "";
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VetProvider>(context, listen: false)
          .cargarDetalleVeterinaria(widget.veterinariaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VetProvider>(context);
    final vet = provider.seleccionada;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. APPBAR ELÁSTICA CON IMAGEN
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary400,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: AppColors.neutral1000),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                vet?.nombre ?? widget.nombrePlaceholder,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  (vet != null && vet.imagenUrl.isNotEmpty)
                      ? Image.network(vet.imagenUrl, fit: BoxFit.cover)
                      : Container(color: AppColors.neutral300, child: const Icon(Icons.store, size: 80, color: Colors.white)),
                  
                  // Degradado para que se lea el texto
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. CONTENIDO
          SliverToBoxAdapter(
            child: provider.isLoading 
              ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
              : (vet == null) 
                  ? const Center(child: Text("Error al cargar información"))
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Dirección y Calificación
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Dirección", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text(vet.direccion, style: const TextStyle(color: AppColors.neutral500)),
                                    const SizedBox(height: 4),
                                    Text(vet.horarioAtencion, style: const TextStyle(color: AppColors.primary400, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 28),
                                  Text(vet.calificacion.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              )
                            ],
                          ),
                          const Divider(height: 40),

                          // Descripción
                          Text("Información", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(vet.descripcion.isEmpty ? "Sin descripción disponible." : vet.descripcion),
                          const SizedBox(height: 24),

                          // Servicios (Chips)
                          Text("Servicios", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                          const SizedBox(height: 4),
                          const Text("Selecciona para revisar disponibilidad:", style: TextStyle(fontSize: 12, color: AppColors.neutral500)),
                          const SizedBox(height: 12),
                          
                          Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: vet.servicios.map((servicio) {
                                  final isSelected = _servicioSeleccionadoId == servicio.id; // ¿Es este el seleccionado?
                                  
                                  return ActionChip(
                                    label: Text(servicio.nombre),
                                    // Si está seleccionado, fondo verde y texto blanco
                                    backgroundColor: isSelected ? AppColors.primary400 : Colors.white,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.primary400, 
                                      fontWeight: FontWeight.bold
                                    ),
                                    side: const BorderSide(color: AppColors.primary400),
                                    
                                    onPressed: () {
                                      setState(() {
                                        _servicioSeleccionadoId = servicio.id;
                                        _nombreServicioSeleccionado = servicio.nombre;
                                      });
                                    },
                                  );
                                }).toList(),
                              ),

                          const SizedBox(height: 40),

                          // Botón Revisar Disponibilidad
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_servicioSeleccionadoId == null) {
                                  // Validación visual
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Por favor selecciona un servicio primero"),
                                      backgroundColor: AppColors.warning,
                                    )
                                  );
                                  return;
                                }

                                // Ahora sí pasamos el ID real
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AvailabilityScreen(
                                      veterinariaId: widget.veterinariaId,
                                      servicioId: _servicioSeleccionadoId!, // <--- ID REAL
                                      nombreVeterinaria: widget.nombrePlaceholder,
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                _servicioSeleccionadoId == null 
                                  ? "Selecciona un servicio" 
                                  : "Revisar Disponibilidad ($_nombreServicioSeleccionado)"
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}