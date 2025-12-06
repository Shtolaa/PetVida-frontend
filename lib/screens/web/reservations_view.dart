import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/web_dashboard_provider.dart';
import 'components/status_badge.dart';

class ReservationsView extends StatelessWidget {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WebDashboardProvider>(context);
    final citas = provider.citas;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Cabecera + Tabla dentro de un contenedor blanco
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Horas Reservadas", style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 24),

        // Filtros (Visuales por ahora)
        Row(
          children: [
            _buildFilterButton(context, Icons.filter_alt_outlined, "Filtrar"),
            const SizedBox(width: 12),
            _buildFilterButton(context, Icons.calendar_today_outlined, "Fecha"),
            const SizedBox(width: 12),
            _buildFilterButton(context, Icons.person_outline, "Veterinario"),
            const Spacer(),
            TextButton.icon(
              onPressed: provider.cargarDashboard, // Recargar
              icon: const Icon(Icons.refresh, color: AppColors.error),
              label: const Text("Recargar Datos", style: TextStyle(color: AppColors.error)),
            )
          ],
        ),
        const SizedBox(height: 20),

        // Contenedor de la Tabla
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: citas.isEmpty
              ? const Center(child: Text("No hay citas registradas"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: DataTable(
                    horizontalMargin: 20,
                    columnSpacing: 20,
                    headingRowColor: MaterialStateProperty.all(Colors.transparent),
                    dataRowColor: MaterialStateProperty.all(Colors.white),
                    dividerThickness: 1, // Líneas sutiles
                    columns: const [
                      DataColumn(label: Text('Fecha', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Dueño', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Mascota', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: citas.map((cita) {
                      return DataRow(
                        cells: [
                          DataCell(Text(cita.fechaTexto)), // Ej: "04 Ago 2025"
                          DataCell(Row(
                            children: [
                              const CircleAvatar(radius: 12, backgroundColor: AppColors.neutral200, child: Icon(Icons.person, size: 14)),
                              const SizedBox(width: 8),
                              Text(cita.nombreDueno),
                            ],
                          )),
                          DataCell(Text(cita.nombreMascota)),
                          DataCell(StatusBadge(status: cita.estado)),
                          DataCell(IconButton(
                            icon: const Icon(Icons.more_vert, color: AppColors.neutral500),
                            onPressed: () {
                              // TODO: Mostrar menú de acciones (Editar, Cancelar)
                            },
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
          ),
        ),
      ],
    );
  }

  // Helper para los botones de filtro
  Widget _buildFilterButton(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.neutral1000),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: AppColors.neutral500),
        ],
      ),
    );
  }
}