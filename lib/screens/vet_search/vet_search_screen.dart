import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../models/vet_model.dart';
import '../../providers/vet_provider.dart';
import 'vet_profile_screen.dart';

class VetSearchScreen extends StatefulWidget {
  const VetSearchScreen({super.key});

  @override
  State<VetSearchScreen> createState() => _VetSearchScreenState();
}

class _VetSearchScreenState extends State<VetSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar las veterinarias apenas entramos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VetProvider>(context, listen: false).cargarVeterinarias();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vetProvider = Provider.of<VetProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: SafeArea(
        child: Column(
          children: [
            // 1. HEADER Y BARRA DE BÚSQUEDA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Veterinarias", style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  
                  // Campo de Texto Búsqueda
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => vetProvider.onSearchChanged(value),
                    decoration: InputDecoration(
                      hintText: "Buscar por nombre...",
                      prefixIcon: const Icon(Icons.search, color: AppColors.neutral500),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.neutral500),
                              onPressed: () {
                                _searchController.clear();
                                vetProvider.onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Filtros (Chips)
                  Row(
                    children: [
                      FilterChip(
                        label: const Text("Solo Abiertas"),
                        selected: vetProvider.soloAbierto,
                        onSelected: (bool selected) {
                          vetProvider.toggleAbierto();
                        },
                        selectedColor: AppColors.primary100,
                        checkmarkColor: AppColors.primary400,
                        labelStyle: TextStyle(
                          color: vetProvider.soloAbierto ? AppColors.primary500 : AppColors.neutral500,
                          fontWeight: vetProvider.soloAbierto ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: vetProvider.soloAbierto ? AppColors.primary400 : AppColors.neutral200,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // 2. LISTA DE RESULTADOS
            Expanded(
              child: vetProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : vetProvider.veterinarias.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: vetProvider.veterinarias.length,
                          itemBuilder: (context, index) {
                            final vet = vetProvider.veterinarias[index];
                            return _VeterinariaCard(vet: vet);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.storefront_outlined, size: 60, color: AppColors.neutral300),
          const SizedBox(height: 16),
          Text(
            "No se encontraron veterinarias",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
               Provider.of<VetProvider>(context, listen: false).cargarVeterinarias();
            }, 
            child: const Text("Recargar lista")
          )
        ],
      ),
    );
  }
}

// Widget separado para la tarjeta individual (Mejor rendimiento y orden)
class _VeterinariaCard extends StatelessWidget {
  final Veterinaria vet;

  const _VeterinariaCard({required this.vet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VetProfileScreen(
                    veterinariaId: vet.id,
                    nombrePlaceholder: vet.nombre,
                  ),
                ),
              );
            },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen (Cuadrada a la izquierda)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 80,
                    height: 80,
                    color: AppColors.neutral200,
                    child: vet.imagenUrl.isNotEmpty
                        ? Image.network(vet.imagenUrl, fit: BoxFit.cover)
                        : const Icon(Icons.local_hospital, color: AppColors.neutral500, size: 30),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre y Badge de Abierto
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              vet.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (vet.estaAbierto)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                "Abierto",
                                style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Dirección
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: AppColors.neutral500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vet.direccion,
                              style: const TextStyle(color: AppColors.neutral500, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Calificación
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            vet.calificacion.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Flecha
                const Icon(Icons.chevron_right, color: AppColors.neutral300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}