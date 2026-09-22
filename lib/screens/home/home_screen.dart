import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../akun/akun_screen.dart';
import '../konsumen/konsumen_screen.dart';
import '../login/login_screen.dart';
import '../prospek/prospek_screen.dart';
import '../cluster/cluster_screen.dart';
import '../bi_checking/bi_checking_screen.dart';
import '../pembangunan/pembangunan_screen.dart';
import '../tipe_rumah/tipe_rumah_screen.dart';
import '../transaksi/transaksi_screen.dart';
import '../unit/unit_screen.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _pages = const [
    DashboardScreen(),
    TransaksiScreen(),
    UnitScreen(),
    KonsumenScreen(),
    AkunScreen(),
  ];

  final _bottomLabels = const ['Dashboard', 'Transaksi', 'Unit', 'Konsumen', 'Pengaturan'];

  Future<void> _openDrawerPage(Widget page) async {
    Navigator.pop(context); // tutup drawer dulu
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await AuthService.instance.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shankara Dev'),
        actions: [
          if (user != null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('Menu Lainnya', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Modul tambahan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    _drawerItem(Icons.person_search_outlined, 'Prospek', const ProspekScreen()),
                    _drawerItem(Icons.business_outlined, 'Cluster', const ClusterScreen()),
                    _drawerItem(Icons.credit_score_outlined, 'BI Checking', const BiCheckingScreen()),
                    _drawerItem(Icons.construction_outlined, 'Pembangunan', const PembangunanScreen()),
                    _drawerItem(Icons.home_work_outlined, 'Tipe Rumah & Paket', const TipeRumahScreen()),
                    const Divider(),
                    _drawerItem(Icons.settings_outlined, 'Pengaturan & Akun', const AkunScreen()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (int i = 0; i < _pages.length; i++)
            NavigationDestination(
              icon: _bottomIcon(i),
              selectedIcon: _bottomIconSelected(i),
              label: _bottomLabels[i],
            ),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, Widget page) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3A8A)),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () => _openDrawerPage(page),
    );
  }

  Icon _bottomIcon(int i) {
    const icons = [
      Icons.dashboard_outlined,
      Icons.receipt_long_outlined,
      Icons.home_outlined,
      Icons.people_outline,
      Icons.settings_outlined,
    ];
    return Icon(icons[i]);
  }

  Icon _bottomIconSelected(int i) {
    const icons = [
      Icons.dashboard,
      Icons.receipt_long,
      Icons.home,
      Icons.people,
      Icons.settings,
    ];
    return Icon(icons[i]);
  }
}