import 'package:flutter/material.dart';

import '../../models/konsumen.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';

class KonsumenDetailScreen extends StatefulWidget {
  final int id;

  const KonsumenDetailScreen({super.key, required this.id});

  @override
  State<KonsumenDetailScreen> createState() => _KonsumenDetailScreenState();
}

class _KonsumenDetailScreenState extends State<KonsumenDetailScreen> {
  late Future<Konsumen> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getKonsumenDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Konsumen')),
      body: FutureBuilder<Konsumen>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail konsumen';
            return Center(child: Text(msg));
          }
          final k = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
            children: [
              _header(k),
              const SizedBox(height: 16),
              _section('Data Pribadi', [
                _row('Nama Lengkap', k.nameLengkap),
                _row('No. KTP', k.noKtp),
                _row('Pekerjaan', k.pekerjaan),
                _row('No. WhatsApp', k.noWhatsapp),
                _row('Alamat KTP', k.alamatKtp),
              ]),
            ],
          );
        },
      ),
    );
  }

  Widget _header(Konsumen k) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
              child: Text(
                inisial(k.nameLengkap),
                style: const TextStyle(
                  color: Color(0xFF1E3A8A),
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                k.nameLengkap,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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