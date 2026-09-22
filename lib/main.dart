import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'config/app_config.dart';
import 'screens/home/home_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppConfig.init();
  await initializeDateFormatting('id_ID', null);
  runApp(const ShandevApp());
}

class ShandevApp extends StatelessWidget {
  const ShandevApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shankara Dev',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        HomeScreen.route: (_) => const HomeScreen(),
      },
    );
  }
}