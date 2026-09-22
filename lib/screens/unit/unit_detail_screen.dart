import 'package:flutter/material.dart';

import '../../models/rumah.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';

class UnitDetailScreen extends StatefulWidget {
  final int id;

  const UnitDetailScreen({super.key, required this.id});

  @override
  State<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends State<UnitDetailScreen> {
  late Future<Rumah> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getRumahDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Unit')),
      body: FutureBuilder<Rumah>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail unit';
            return Center(child: Text(msg));
          }
          final r = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _header(r),
              const SizedBox(height: 16),
              _section('Informasi Unit', [
                _row('No. Blok', r.noBlok),
                _row('Cluster', r.clusterName),
                _row('Tipe Rumah', r.tipeRumah),
              ]),
              const SizedBox(height: 16),
              _section('Spesifikasi', [
                _row('Luas Tanah', r.luasTanah != null ? '${r.luasTanah} m²' : '-'),
                _row('Luas Bangunan', r.luasBangunan != null ? '${r.luasBangunan} m²' : '-'),
                _row('Harga Jual', formatRupiah(r.hargaJual)),
              ]),
              const SizedBox(height: 16),
              _section('Status', [
                _row('Status Unit', statusUnitLabel(r.statusUnit)),
                _row('No. SHM', r.noShm),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _header(Rumah r) {
    final color = switch (r.statusUnit) {
      'tersedia' => const Color(0xFF2563EB),
      'booking' => const Color(0xFFD97706),
      'terjual' => const Color(0xFF059669),
      _ => const Color(0xFF6B7280),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.home_work_outlined, size: 34, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.noBlok,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.clusterName} · ${r.tipeRumah}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  StatusChip(label: statusUnitLabel(r.statusUnit), status: r.statusUnit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 10),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}