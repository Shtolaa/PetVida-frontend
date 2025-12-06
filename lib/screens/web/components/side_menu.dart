import 'package:flutter/material.dart';
import '../../../config/theme/app_theme.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // 1. LOGO
          Container(
            height: 100,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.pets, color: AppColors.primary400, size: 28),
                const SizedBox(width: 8),
                Text(
                  "PetVet",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. OPCIONES DE MENÚ
          _DrawerListTile(
            title: "Dashboard",
            icon: Icons.dashboard_outlined,
            isSelected: selectedIndex == 0,
            onTap: () => onIndexChanged(0),
          ),
          _DrawerListTile(
            title: "Veterinarios",
            icon: Icons.person_outline,
            isSelected: selectedIndex == 1,
            onTap: () => onIndexChanged(1),
          ),
          _DrawerListTile(
            title: "Horas Reservadas",
            icon: Icons.list_alt,
            isSelected: selectedIndex == 2,
            onTap: () => onIndexChanged(2),
          ),
          _DrawerListTile(
            title: "Calendario",
            icon: Icons.calendar_today_outlined,
            isSelected: selectedIndex == 3,
            onTap: () => onIndexChanged(3),
          ),

          const Spacer(), // Empuja lo siguiente hacia abajo

          // 3. SETTINGS Y LOGOUT
          const Divider(),
          _DrawerListTile(
            title: "Settings",
            icon: Icons.settings_outlined,
            isSelected: selectedIndex == 4,
            onTap: () => onIndexChanged(4),
          ),
          _DrawerListTile(
            title: "Logout",
            icon: Icons.logout,
            isSelected: false,
            onTap: () {
              // TODO: Lógica de Logout
              Navigator.pop(context); // Temporal
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerListTile({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos el color activo. 
    // Usamos el AZUL del diseño (aprox 0xFF448AFF) o puedes cambiarlo por AppColors.primary400 si prefieres verde.
    final activeColor = AppColors.primary300;

    return Container(
      // Margen horizontal para que el botón no toque los bordes (estilo tarjeta flotante)
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      
      // AQUÍ ESTÁ EL TRUCO: Pintamos el fondo nosotros mismos
      decoration: BoxDecoration(
        color: isSelected ? activeColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      
      child: ListTile(
        onTap: onTap,
        horizontalTitleGap: 12,
        
        // Icono
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : AppColors.neutral500,
          size: 22,
        ),
        
        // Texto
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.neutral500,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        
        // Importante: Desactivamos el estilo nativo de selección para que no interfiera
        selected: false, 
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        
        // Hover effect (opcional, para que se vea bonito en web)
        hoverColor: activeColor.withOpacity(0.1),
      ),
    );
  }
}