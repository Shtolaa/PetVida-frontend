import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../auth/login_screen.dart'; 
import 'add_pet_screen.dart'; 
import 'edit_profile_screen.dart';
import 'edit_pet_screen.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).cargarPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final user = profileProvider.usuario;

    if (profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No se pudo cargar el perfil"),
            TextButton(
                onPressed: profileProvider.cargarPerfil,
                child: const Text("Reintentar"))
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: AppBar(
        title: const Text("Cuenta"),
        actions: [
          TextButton(
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            },
            child: const Text("Editar", style: TextStyle(color: AppColors.primary400, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. CABECERA DE PERFIL
            Row(
              children: [
                // --- CORRECCIÓN FOTO USUARIO ---
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.neutral200,
                  backgroundImage: (user.fotoPerfilUrl.isNotEmpty && user.fotoPerfilUrl.startsWith("http")) 
                      ? NetworkImage(user.fotoPerfilUrl) 
                      : null,
                  child: (user.fotoPerfilUrl.isEmpty || !user.fotoPerfilUrl.startsWith("http")) 
                      ? const Icon(Icons.person, size: 40, color: AppColors.neutral500)
                      : null,
                ),
                // -------------------------------
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.nombreCompleto,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 30),

            // 2. SECCIÓN MIS MASCOTAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Mis Mascotas", style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18)),
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPetScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Agregar Mascota"),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary400),
                )
              ],
            ),
            const SizedBox(height: 10),

            if (user.mascotas.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Text("No tienes mascotas registradas aún.", textAlign: TextAlign.center),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: user.mascotas.length,
                itemBuilder: (context, index) {
                  final mascota = user.mascotas[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.neutral200),
                    ),
                    child: ListTile(
                      // --- CORRECCIÓN FOTO MASCOTA ---
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary100,
                        backgroundImage: (mascota.fotoUrl.isNotEmpty && mascota.fotoUrl.startsWith("http")) 
                          ? NetworkImage(mascota.fotoUrl) 
                          : null,
                        child: (mascota.fotoUrl.isEmpty || !mascota.fotoUrl.startsWith("http")) 
                          ? const Icon(Icons.pets, color: AppColors.primary400)
                          : null,
                      ),
                      // -------------------------------
                      title: Text(mascota.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(mascota.especie),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primary400),
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => EditPetScreen(mascota: mascota)));
                        },
                      ),
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // 3. OPCIONES EXTRA
            _buildOptionTile(context, "Ver todas las visitas", Icons.calendar_month_outlined, () {}),
            
            const SizedBox(height: 10),
            
            // Botón Cerrar Sesión
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neutral200),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text("Cerrar Sesión", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                onTap: () async {
                   await profileProvider.cerrarSesion();
                   if (context.mounted) {
                     Navigator.pushAndRemoveUntil(
                       context, 
                       MaterialPageRoute(builder: (_) => const LoginScreen()), 
                       (route) => false
                     );
                   }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary400),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.neutral300),
        onTap: onTap,
      ),
    );
  }
}