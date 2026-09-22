import 'package:flutter/material.dart';

import '../../models/pembangunan.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';

class PembangunanDetailScreen extends StatefulWidget {
  final int id;

  const PembangunanDetailScreen({super.key, required this.id});

  @override
  State<PembangunanDetailScreen> createState() => _PembangunanDetailScreenState();
}

class _PembangunanDetailScreenState extends State<PembangunanDetailScreen> {
  late Future<Pembangunan> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getPembangunanDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Progres Pembangunan')),
      body: FutureBuilder<Pembangunan>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail pembangunan';
            return Center(child: Text(msg));
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _header(p),
              const SizedBox(height: 16),
              _section('Info Unit', [
                _row('Cluster', p.clusterName),
                _row('No. Blok', p.noBlok),
                _row('Tipe Rumah', p.tipeRumah),
                if (p.nameLengkap != null && p.nameLengkap!.isNotEmpty)
                  _row('Konsumen', p.nameLengkap!),
              ]),
              const SizedBox(height: 12),
              _section('Progres', [
                _row('Status', p.statusPembangunan),
                _row('Persentase', '${p.persentaseProgres}%'),
                if (p.tglMulai != null && p.tglMulai!.isNotEmpty)
                  _row('Tgl Mulai', p.tglMulai!),
                if (p.tglTargetSelesai != null && p.tglTargetSelesai!.isNotEmpty)
                  _row('Target Selesai', p.tglTargetSelesai!),
              ]),
              const SizedBox(height: 12),
              _section('Visualisasi Progres', [
                LinearProgressIndicator(
                  value: p.persentaseProgres / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_progressColor(p.statusPembangunan)),
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 8),
                Text(
                  '${p.persentaseProgres}%  —  ${p.statusPembangunan}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ]),
              const SizedBox(height: 12),
              if (p.catatanLapangan != null && p.catatanLapangan!.isNotEmpty)
                _section('Catatan Lapangan', [
                  _row('Catatan', p.catatanLapangan!),
                ]),
              const SizedBox(height: 12),
              _section('Timeline', [
                if (p.tglMulai != null && p.tglMulai!.isNotEmpty)
                  _row('Tgl Mulai', p.tglMulai!),
                if (p.tglTargetSelesai != null && p.tglTargetSelesai!.isNotEmpty)
                  _row('Target Selesai', p.tglTargetSelesai!),
                _row('Dibuat', p.createdAt),
                _row('Diperbarui', p.updatedAt),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _header(Pembangunan p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.12),
              child: Text(
                inisial(p.clusterName),
                style: const TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${p.clusterName} - Blok ${p.noBlok}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('Tipe: ${p.tipeRumah}', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 4),
                  StatusChip(label: p.statusPembangunan, status: p.statusPembangunan),
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

  Color _progressColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF059669);
      case 'Finishing':
        return const Color(0xFF7C3AED);
      case 'Struktur':
        return const Color(0xFF2563EB);
      case 'Pondasi':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }
}