import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/web_dashboard_provider.dart';
import 'components/side_menu.dart';
import 'dashboard_view.dart';
import 'reservations_view.dart';

class WebLayoutScreen extends StatefulWidget {
  const WebLayoutScreen({super.key});

  @override
  State<WebLayoutScreen> createState() => _WebLayoutScreenState();
}

class _WebLayoutScreenState extends State<WebLayoutScreen> {
  int _selectedIndex = 0; // 0: Dashboard, 1: Vets, 2: Reservas...

  @override
  void initState() {
    super.initState();
    // Cargar datos apenas entramos al dashboard web
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WebDashboardProvider>(context, listen: false).cargarDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA), // Fondo gris muy claro típico de dashboards
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SIDEBAR (Ocupa 250px fijos o un porcentaje)
          SizedBox(
            width: 250,
            child: SideMenu(
              selectedIndex: _selectedIndex,
              onIndexChanged: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),

          // 2. ÁREA DE CONTENIDO (El resto de la pantalla)
          Expanded(
            child: Column(
              children: [
                // Header Superior (Buscador y Perfil)
                _buildWebHeader(),
                
                // Contenido cambiante
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: _buildContent(_selectedIndex),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header blanco superior
  Widget _buildWebHeader() {
    return Container(
      height: 70,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: [
          // Barra de búsqueda
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search, color: AppColors.neutral300),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
                fillColor: Colors.transparent, 
                filled: false,
              ),
            ),
          ),
          const Spacer(),
          // Perfil a la derecha
          const CircleAvatar(
            backgroundImage: NetworkImage("https://via.placeholder.com/150"),
            backgroundColor: AppColors.neutral200,
          ),
          const SizedBox(width: 10),
          const Text("Veterinaria Ejemplo 1", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Switch para cambiar de vistas
    Widget _buildContent(int index) {
        switch (index) {
          case 0:
            return const DashboardView();
          case 2:
            return const ReservationsView();
          default:
            return Center(child: Text("Página en construcción (Index: $index)"));
        }
      }
}