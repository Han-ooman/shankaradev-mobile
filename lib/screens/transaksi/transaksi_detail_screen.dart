import 'package:flutter/material.dart';

import '../../models/transaksi.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';

class TransaksiDetailScreen extends StatefulWidget {
  final int id;

  const TransaksiDetailScreen({super.key, required this.id});

  @override
  State<TransaksiDetailScreen> createState() => _TransaksiDetailScreenState();
}

class _TransaksiDetailScreenState extends State<TransaksiDetailScreen> {
  late Future<Transaksi> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getTransaksiDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaksi #${widget.id}')),
      body: FutureBuilder<Transaksi>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final msg = snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Gagal memuat detail';
            return Center(child: Text(msg));
          }
          final t = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = ApiService.instance.getTransaksiDetail(widget.id);
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              children: [
                _header(t),
                const SizedBox(height: 16),
                _section('Konsumen', [
                  _row('Nama', t.nameLengkap),
                ]),
                const SizedBox(height: 16),
                _section('Unit', [
                  _row('No. Blok', t.noBlok),
                  _row('Cluster', t.clusterName),
                  _row('Tipe Rumah', t.tipeRumah),
                  _row('Luas Tanah', t.luasTanah != null ? '${t.luasTanah} m²' : '-'),
                  _row('Luas Bangunan', t.luasBangunan != null ? '${t.luasBangunan} m²' : '-'),
                  _row('Harga Jual', formatRupiah(t.hargaJual)),
                ]),
                const SizedBox(height: 16),
                _section('Pembayaran & Akad', [
                  _row('Skema Bayar', t.skemaBayar),
                  _row('Skema Akad', t.skemaAkad),
                  _row('Status KPR', t.statusKonsumen),
                  _row('Status Bank', t.statusBank),
                  _row('Tanggal Booking', formatTanggal(t.tglBooking)),
                  _row('Tanggal Akad', formatTanggal(t.tanggalAkad)),
                  _row('Deadline Berkas', formatTanggal(t.deadlineBerkas)),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(Transaksi t) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    t.nameLengkap,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ),
                StatusChip(label: t.statusKonsumen, status: t.statusKonsumen),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${t.noBlok} · ${t.clusterName}',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}