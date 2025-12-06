import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Importar gráfico
import '../../config/theme/app_theme.dart';
import '../../providers/web_dashboard_provider.dart';
import 'components/kpi_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WebDashboardProvider>(context);
    final metrics = provider.metrics;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (metrics == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No se pudieron cargar las métricas"),
            TextButton(
              onPressed: provider.cargarDashboard, 
              child: const Text("Reintentar")
            )
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Dashboard", style: Theme.of(context).textTheme.displayMedium),
        const SizedBox(height: 24),

        // 1. FILA DE TARJETAS (KPIs)
        // Usamos LayoutBuilder para que se adapte si la pantalla es chica
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculamos ancho para que quepan 4 o menos
            final width = constraints.maxWidth;
            final cardWidth = (width - (20 * 3)) / 4; // 20 de espacio * 3 huecos

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: "Horas agendadas\neste Mes",
                    value: metrics.horasAgendadas.valor.toString(),
                    icon: Icons.people,
                    color: const Color(0xFF5E60CE), // Morado
                    trend: metrics.horasAgendadas.mensajeTendencia,
                    isPositive: metrics.horasAgendadas.tendencia == "POSITIVA",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: "Horas Canceladas\neste Mes",
                    value: metrics.horasCanceladas.valor.toString(),
                    icon: Icons.history,
                    color: const Color(0xFFFF8A65), // Naranja
                    trend: metrics.horasCanceladas.mensajeTendencia,
                    isPositive: metrics.horasCanceladas.tendencia == "POSITIVA", 
                    // Nota: Si aumentan las cancelaciones, suele ser negativo para el negocio, 
                    // pero aquí respetamos lo que diga el back en "isPositive".
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: "Interacciones con su\nPágina este Mes",
                    value: metrics.interacciones.valor.toString(),
                    icon: Icons.show_chart,
                    color: AppColors.success, // Verde
                    trend: metrics.interacciones.mensajeTendencia,
                    isPositive: metrics.interacciones.tendencia == "POSITIVA",
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: KpiCard(
                    title: "Horas agendadas\npara hoy",
                    value: metrics.horasHoy.valor.toString(),
                    icon: Icons.calendar_today,
                    color: AppColors.secondary400, // Turquesa
                    trend: metrics.horasHoy.mensajeTendencia,
                    isPositive: metrics.horasHoy.tendencia == "POSITIVA",
                  ),
                ),
              ],
            );
          }
        ),

        const SizedBox(height: 30),

        // 2. GRÁFICO GRANDE
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(metrics.tituloGrafico, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text("Agosto"), // Podría ser dinámico
                    )
                  ],
                ),
                const SizedBox(height: 24),
                
                // El Gráfico de Línea
                Expanded(
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (value) => const FlLine(
                          color: AppColors.neutral200, strokeWidth: 1
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              // Mapeamos el índice del gráfico a la etiqueta del backend
                              int index = value.toInt();
                              if (index >= 0 && index < metrics.datosGrafico.length) {
                                // Mostramos solo algunas etiquetas para no saturar
                                if (index % 2 == 0) { // Mostrar par por medio
                                   return Padding(
                                     padding: const EdgeInsets.only(top: 8.0),
                                     child: Text(metrics.datosGrafico[index].etiqueta, style: const TextStyle(fontSize: 10, color: AppColors.neutral500)),
                                   );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: metrics.datosGrafico.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value.valor.toDouble());
                          }).toList(),
                          isCurved: true,
                          color: const Color(0xFF448AFF), // Azul gráfico
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF448AFF).withOpacity(0.1), // Relleno suave
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}