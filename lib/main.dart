import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'providers/home_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/vet_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/web_dashboard_provider.dart';
import 'screens/web/web_layout_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // Aseguramos que los widgets estén listos antes de inicializar cosas asíncronas
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos el formateo de fechas para español (y otros si los necesitas)
  await initializeDateFormatting('es'); 

  runApp(const PetVidaApp());
}

class PetVidaApp extends StatelessWidget {
  const PetVidaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider permite tener varios estados globales (Auth, Citas, etc.)
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => VetProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => WebDashboardProvider()),
      ],
      child: MaterialApp(
        title: 'PetVida',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const LoginScreen(), // Establecemos Login como pantalla inicial
      ),
    );
  }
}
