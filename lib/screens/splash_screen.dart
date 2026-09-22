import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import 'home/home_screen.dart';
import 'login/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const route = '/';

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    await AuthService.instance.init();
    // Coba validasi sesi yang tersimpan
    var loggedIn = AuthService.instance.isLoggedIn;
    if (loggedIn) {
      try {
        final res = await ApiClient.instance.get('/auth/check');
        loggedIn = res['data']?['valid'] == true;
      } catch (_) {
        loggedIn = false;
      }
    }
    if (!mounted) return;
    if (loggedIn) {
      Navigator.of(context).pushReplacementNamed(HomeScreen.route);
    } else {
      await AuthService.instance.clear();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(LoginScreen.route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      backgroundColor: primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)],
              ),
              child: const Icon(Icons.home_work, size: 46, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Shankara Dev',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Perumahan & KPR',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}