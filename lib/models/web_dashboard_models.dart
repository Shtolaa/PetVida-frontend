// === MODELOS PARA EL DASHBOARD (KPIs y Gráfico) ===

class KpiItem {
  final int valor;
  final String tendencia; // "POSITIVA" o "NEGATIVA"
  final String mensajeTendencia; // "20 Más que el mes pasado"

  KpiItem({required this.valor, required this.tendencia, required this.mensajeTendencia});

  factory KpiItem.fromJson(Map<String, dynamic> json) {
    return KpiItem(
      valor: json['valor'] ?? 0,
      tendencia: json['tendencia'] ?? 'NEUTRA',
      mensajeTendencia: json['mensajeTendencia'] ?? '',
    );
  }
}

class GraficoPunto {
  final String etiqueta;
  final int valor;

  GraficoPunto({required this.etiqueta, required this.valor});

  factory GraficoPunto.fromJson(Map<String, dynamic> json) {
    return GraficoPunto(
      etiqueta: json['etiqueta'] ?? '',
      valor: json['valor'] ?? 0,
    );
  }
}

class DashboardResponse {
  final KpiItem horasAgendadas;
  final KpiItem horasCanceladas;
  final KpiItem interacciones;
  final KpiItem horasHoy;
  final String tituloGrafico;
  final List<GraficoPunto> datosGrafico;

  DashboardResponse({
    required this.horasAgendadas,
    required this.horasCanceladas,
    required this.interacciones,
    required this.horasHoy,
    required this.tituloGrafico,
    required this.datosGrafico,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    final kpis = json['resumenKpis'] ?? {};
    final grafico = json['graficoLineal'] ?? {};
    final listaPuntos = grafico['datos'] as List? ?? [];

    return DashboardResponse(
      horasAgendadas: KpiItem.fromJson(kpis['horasAgendadasMes'] ?? {}),
      horasCanceladas: KpiItem.fromJson(kpis['horasCanceladasMes'] ?? {}),
      interacciones: KpiItem.fromJson(kpis['interaccionesPagina'] ?? {}),
      horasHoy: KpiItem.fromJson(kpis['horasHoy'] ?? {}),
      tituloGrafico: grafico['titulo'] ?? 'Resumen',
      datosGrafico: listaPuntos.map((p) => GraficoPunto.fromJson(p)).toList(),
    );
  }
}

// === MODELO PARA LA TABLA DE CITAS ===

class CitaVeterinaria {
  final int idCita;
  final String fechaTexto;
  final String nombreDueno; // El DTO no lo trae, pondremos un placeholder
  final String nombreMascota;
  final String estado;

  CitaVeterinaria({
    required this.idCita,
    required this.fechaTexto,
    required this.nombreDueno,
    required this.nombreMascota,
    required this.estado,
  });

  factory CitaVeterinaria.fromJson(Map<String, dynamic> json) {
    // 1. Armar fecha bonita desde los datos planos de Java
    final fecha = json['fecha']?.toString() ?? '';
    final hora = json['hora']?.toString() ?? '';
    final fechaCompuesta = "$fecha $hora";

    return CitaVeterinaria(
      idCita: json['id'] ?? 0, // Java manda 'id', no 'idCita'
      fechaTexto: fechaCompuesta,
      // OJO: AppointmentResponseDTO no trae nombre del dueño. 
      // Si el back no lo agrega, mostraremos "Cliente" o usaremos el ID si viene.
      nombreDueno: "Cliente", 
      nombreMascota: json['nombreMascota'] ?? 'Mascota',
      estado: json['estado'] ?? 'PENDIENTE',
    );
  }
}