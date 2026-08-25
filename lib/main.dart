import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'config/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/agenda_provider.dart';
import 'providers/vehiculo_provider.dart';
import 'providers/orden_provider.dart';
import 'providers/compra_provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(const SigotApp());
}

class SigotApp extends StatelessWidget {
  const SigotApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => AgendaProvider()),
          ChangeNotifierProvider(create: (_) => VehiculoProvider()),
          ChangeNotifierProvider(create: (_) => OrdenProvider()),
          ChangeNotifierProvider(create: (_) => CompraProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ],
        child: MaterialApp(
          title: 'SIGOT',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          home: const SplashScreen(),
        ),
      );
}
