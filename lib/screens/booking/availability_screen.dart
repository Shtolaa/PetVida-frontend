import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/booking_provider.dart';
import 'confirm_booking_screen.dart';

class AvailabilityScreen extends StatefulWidget {
  final int veterinariaId;
  final int servicioId;
  final String nombreVeterinaria;

  const AvailabilityScreen({
    super.key,
    required this.veterinariaId,
    required this.servicioId,
    required this.nombreVeterinaria,
  });

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Inicializamos el provider con los datos que vienen de la pantalla anterior
      Provider.of<BookingProvider>(context, listen: false)
          .setVeterinariaYServicio(widget.veterinariaId, widget.servicioId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.nombreVeterinaria)),
      body: Column(
        children: [
          // 1. Selector de Fechas Horizontal
          Container(
            height: 90,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 14, // Próximas 2 semanas
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              itemBuilder: (context, index) {
                final fecha = DateTime.now().add(Duration(days: index));
                final isSelected = DateUtils.isSameDay(fecha, bookingProvider.fechaSeleccionada);
                
                // Formatos: "LU", "24"
                final diaSemana = DateFormat('EE', 'es').format(fecha).toUpperCase().substring(0, 2); // Requiere inicializar locale, o usar substring simple en ingles por ahora
                final numeroDia = fecha.day.toString();

                return GestureDetector(
                  onTap: () => bookingProvider.cargarHorarios(fecha),
                  child: Container(
                    width: 60,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary400 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary400 : AppColors.neutral200),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(diaSemana, style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.neutral500, fontSize: 12
                        )),
                        Text(numeroDia, style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.neutral1000, 
                          fontWeight: FontWeight.bold, fontSize: 18
                        )),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const Divider(),

          // 2. Grilla de Horarios
          Expanded(
            child: bookingProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookingProvider.bloques.isEmpty
                    ? const Center(child: Text("No hay horas disponibles este día"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: bookingProvider.bloques.length,
                        itemBuilder: (context, index) {
                          final bloque = bookingProvider.bloques[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bloque.titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: bloque.horarios.map((hora) {
                                  final isSelected = bookingProvider.horaSeleccionada == hora;
                                  return ChoiceChip(
                                    label: Text(hora),
                                    selected: isSelected,
                                    onSelected: (selected) => bookingProvider.seleccionarHora(hora),
                                    selectedColor: AppColors.primary400,
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.neutral1000,
                                    ),
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: BorderSide(color: isSelected ? Colors.transparent : AppColors.neutral300)
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
          ),

          // 3. Botón Continuar
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: bookingProvider.horaSeleccionada == null
                    ? null // Deshabilitado si no hay hora
                    : () {
                        // TODO: Ir a pantalla de Confirmación
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ConfirmBookingScreen(
                              nombreVeterinaria: widget.nombreVeterinaria,
                              nombreServicio: "Servicio Veterinario", // Puedes mejorar esto pasándolo desde VetProfile
                            ),
                          ),
                        );
                      },
                child: const Text("Confirmar Hora"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}