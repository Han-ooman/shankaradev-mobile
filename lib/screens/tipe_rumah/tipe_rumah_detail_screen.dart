import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../utils/formatters.dart';

class TipeRumahDetailScreen extends StatefulWidget {
  final int id;

  const TipeRumahDetailScreen({super.key, required this.id});

  @override
  State<TipeRumahDetailScreen> createState() => _TipeRumahDetailScreenState();
}

class _TipeRumahDetailScreenState extends State<TipeRumahDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.instance.get('/tipe-rumah/${widget.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tipe Rumah & Paket')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail tipe rumah';
            return Center(child: Text(msg));
          }
          final t = snapshot.data!['data'] as Map<String, dynamic>;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _header(t),
              const SizedBox(height: 16),
              _section('Informasi Paket', [
                _row('Tipe Rumah', t['tipe_rumah'] as String? ?? ''),
                _row('Harga', formatRupiah(int.tryParse('${t['harga']}') ?? 0)),
                _row('DP Persen', '${(t['dp_persen'] as num?)?.toStringAsFixed(2) ?? '0'}%'),
                _row('DP Nominal', formatRupiah(int.tryParse('${t['dp_nominal']}') ?? 0)),
                _row('Angsuran / Bulan', formatRupiah(int.tryParse('${t['angsuran']}') ?? 0)),
                _row('Tenor', '${t['tenor_bulan'] ?? 0} Bulan'),
              ]),
              const SizedBox(height: 12),
              if ((t['persyaratan'] as String?)?.isNotEmpty == true)
                _section('Persyaratan', [
                  _row('Persyaratan', t['persyaratan'] as String? ?? '-'),
                ]),
              const SizedBox(height: 12),
              if ((t['keterangan'] as String?)?.isNotEmpty == true)
                _section('Keterangan', [
                  _row('Keterangan', t['keterangan'] as String? ?? '-'),
                ]),
              const SizedBox(height: 12),
              _section('Timeline', [
                _row('Dibuat', t['created_at'] as String? ?? '-'),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _header(Map<String, dynamic> t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
              child: const Icon(Icons.home_outlined, color: Color(0xFF1E3A8A), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t['tipe_rumah'] as String? ?? '',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Harga: ${formatRupiah(int.tryParse("${t['harga']}") ?? 0)}',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
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