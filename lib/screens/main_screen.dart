import 'package:flutter/material.dart';
import '../config/theme/app_theme.dart';
import 'home/home_view.dart';
import 'user_profile/profile_view.dart'; 

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1; // Empezamos en el Home (índice 1)

  // Lista de pantallas para navegar
  final List<Widget> _screens = [
    const Center(child: Text("Buscador de Veterinarias")), // Placeholder Indice 0
    const HomeView(),                                      // Indice 1 (La que haremos ahora)
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El body cambia según el ícono seleccionado
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (value) => setState(() => _selectedIndex = value),
          
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.secondary400,
          unselectedItemColor: AppColors.neutral300,
          showSelectedLabels: false, // Estilo minimalista del diseño
          showUnselectedLabels: false,
          elevation: 0,
          iconSize: 28,
          
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              activeIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}