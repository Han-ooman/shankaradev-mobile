import 'package:flutter/material.dart';

import '../../models/dashboard.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiService.instance.getDashboard();
  }

  void _reload() {
    setState(() {
      _future = ApiService.instance.getDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final msg = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Gagal memuat data';
          return _errorView(msg);
        }
        final d = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _summaryCards(d),
              const SizedBox(height: 20),
              _sectionTitle('Ringkasan Transaksi'),
              const SizedBox(height: 10),
              _transaksiStats(d),
              const SizedBox(height: 20),
              _sectionTitle('Pembayaran Bulan Ini'),
              const SizedBox(height: 10),
              _pembayaranCard(d.totalBayarBulanIni),
              const SizedBox(height: 20),
              _sectionTitle('Unit per Cluster'),
              const SizedBox(height: 10),
              _clusterList(d.cluster),
              const SizedBox(height: 20),
              _sectionTitle('Transaksi Terbaru'),
              const SizedBox(height: 10),
              _recentList(d.recentTransaksi),
            ],
          ),
        );
      },
    );
  }

  Widget _errorView(String msg) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(msg, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh), label: const Text('Muat Ulang')),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards(DashboardSummary d) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Unit Tersedia',
            value: '${d.unitTersedia}',
            icon: Icons.home_work_outlined,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Unit Booking',
            value: '${d.unitBooking}',
            icon: Icons.event_available,
            color: const Color(0xFFD97706),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            label: 'Terjual',
            value: '${d.unitTerjual}',
            icon: Icons.check_circle_outline,
            color: const Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    );
  }

  Widget _transaksiStats(DashboardSummary d) {
    final items = [
      ('Total Transaksi', d.totalTransaksi, const Color(0xFF1E3A8A)),
      ('Proses', d.proses, const Color(0xFFD97706)),
      ('ACC - Akad', d.accAkad, const Color(0xFF059669)),
      ('Akad Bank', d.akadBank, const Color(0xFF7C3AED)),
      ('Batal', d.batal, const Color(0xFFDC2626)),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((e) => _miniStat(e.$1, e.$2, e.$3)).toList(),
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _pembayaranCard(int total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payments_outlined, color: Color(0xFF059669), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pembayaran', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    formatRupiah(total),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clusterList(List<ClusterStat> clusters) {
    if (clusters.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Tidak ada data')));
    }
    return Card(
      child: Column(
        children: [
          for (var c in clusters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(c.clusterName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  Expanded(
                    child: _dot('${c.tersedia}', const Color(0xFF2563EB)),
                  ),
                  Expanded(
                    child: _dot('${c.booking}', const Color(0xFFD97706)),
                  ),
                  Expanded(
                    child: _dot('${c.terjual}', const Color(0xFF059669)),
                  ),
                ],
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Expanded(flex: 3, child: Text('', style: TextStyle(fontSize: 12))),
                const Expanded(child: Text('Tersedia', style: TextStyle(fontSize: 10, color: Colors.grey))),
                const Expanded(child: Text('Booking', style: TextStyle(fontSize: 10, color: Colors.grey))),
                const Expanded(child: Text('Terjual', style: TextStyle(fontSize: 10, color: Colors.grey))),
              ],
            ),
          ),
        ].reversed.toList(),
      ),
    );
  }

  Widget _dot(String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
      ],
    );
  }

  Widget _recentList(List<RecentTransaksi> items) {
    if (items.isEmpty) {
      return const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Tidak ada transaksi terbaru')));
    }
    return Card(
      child: Column(
        children: [
          for (var t in items)
            ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                child: Text(
                  inisial(t.nameLengkap),
                  style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              title: Text(t.nameLengkap, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              subtitle: Text(
                '${t.noBlok} · ${t.clusterName}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: StatusChip(
                label: t.statusKonsumen,
                status: t.statusKonsumen,
                compact: true,
              ),
            ),
        ],
      ),
    );
  }
}