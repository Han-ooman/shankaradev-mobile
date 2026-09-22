import 'package:flutter/material.dart';

import '../../models/prospek.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';

class ProspekDetailScreen extends StatefulWidget {
  final int id;

  const ProspekDetailScreen({super.key, required this.id});

  @override
  State<ProspekDetailScreen> createState() => _ProspekDetailScreenState();
}

class _ProspekDetailScreenState extends State<ProspekDetailScreen> {
  late Future<Prospek> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getProspekDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Prospek')),
      body: FutureBuilder<Prospek>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail prospek';
            return Center(child: Text(msg));
          }
          final p = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _header(p),
              const SizedBox(height: 16),
              _section('Data Pribadi', [
                _row('Nama Lengkap', p.nameLengkap),
                _row('No. KTP', p.noKtp),
                _row('Pekerjaan', p.pekerjaan),
                _row('No. WhatsApp', p.noWhatsapp),
              ]),
              const SizedBox(height: 12),
              _section('Informasi Minat', [
                _row('Sumber', p.sumber),
                _row('Cluster Minat', p.clusterMinat.isEmpty ? '-' : p.clusterMinat),
                _row('Unit Minat', p.unitMinat.isEmpty ? '-' : p.unitMinat),
                _row('Status Follow-up', p.statusFollowup),
                if (p.tanggalFollowup != null && p.tanggalFollowup!.isNotEmpty)
                  _row('Tanggal Follow-up', p.tanggalFollowup!),
              ]),
              const SizedBox(height: 12),
              if (p.catatan.isNotEmpty)
                _section('Catatan', [
                  _row('Catatan', p.catatan),
                ]),
              const SizedBox(height: 12),
              _section('Timeline', [
                _row('Dibuat', p.createdAt),
                _row('Diperbarui', p.updatedAt),
              ]),
              const SizedBox(height: 24),
              if (p.statusFollowup != 'Deal')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Tandai Deal (Pindah ke Konsumen)'),
                    onPressed: () => _dealProspek(p.idProspek),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _dealProspek(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Deal'),
        content: const Text('Prospek ini akan dipindahkan ke data konsumen dan status diubah ke Deal. Lanjutkan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Deal')),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiService.instance.dealProspek(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prospek berhasil di-deal')),
        );
        Navigator.pop(context, true); // kembali ke list dengan refresh
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Widget _header(Prospek p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF7C3AED).withValues(alpha: 0.12),
              child: Text(
                inisial(p.nameLengkap),
                style: const TextStyle(
                  color: Color(0xFF7C3AED),
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
                    p.nameLengkap,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: p.statusFollowup, status: p.statusFollowup),
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