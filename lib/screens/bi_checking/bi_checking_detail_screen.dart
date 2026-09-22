import 'package:flutter/material.dart';

import '../../models/bi_checking.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';

class BiCheckingDetailScreen extends StatefulWidget {
  final int id;

  const BiCheckingDetailScreen({super.key, required this.id});

  @override
  State<BiCheckingDetailScreen> createState() => _BiCheckingDetailScreenState();
}

class _BiCheckingDetailScreenState extends State<BiCheckingDetailScreen> {
  late Future<BiChecking> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getBiCheckingDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail BI Checking')),
      body: FutureBuilder<BiChecking>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail BI checking';
            return Center(child: Text(msg));
          }
          final b = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _header(b),
              const SizedBox(height: 16),
              _section('Data Konsumen', [
                _row('Nama Lengkap', b.nameLengkap),
                _row('No. KTP', b.noKtp ?? '-'),
                _row('Pekerjaan', b.pekerjaan ?? '-'),
                _row('No. WhatsApp', b.noWhatsapp ?? '-'),
                _row('Alamat KTP', b.alamatKtp ?? '-'),
              ]),
              const SizedBox(height: 12),
              _section('Informasi BI Checking', [
                _row('Tanggal Cek', b.tglCek),
                _row('Lembaga', b.lembaga ?? '-'),
                _row('No. Pengajuan', b.noPengajuan ?? '-'),
                _row('Marketing', b.namaMarketing ?? '-'),
                _row('Hasil BI', b.hasilBi),
              ]),
              const SizedBox(height: 12),
              if (b.catatan != null && b.catatan!.isNotEmpty)
                _section('Catatan', [
                  _row('Catatan', b.catatan!),
                ]),
              const SizedBox(height: 12),
              _section('Timeline', [
                _row('Dibuat', b.createdAt),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BiChecking b) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF059669).withValues(alpha: 0.12),
              child: Text(
                inisial(b.nameLengkap),
                style: const TextStyle(
                  color: Color(0xFF059669),
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
                    b.nameLengkap,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  StatusChip(label: b.hasilBi, status: b.hasilBi),
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