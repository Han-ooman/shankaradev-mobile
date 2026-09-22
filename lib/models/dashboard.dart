class DashboardSummary {
  final int totalTransaksi;
  final int proses;
  final int accAkad;
  final int akadBank;
  final int batal;

  final int totalUnit;
  final int unitTersedia;
  final int unitBooking;
  final int unitTerjual;

  final int totalBayarBulanIni;
  final List<ClusterStat> cluster;
  final List<RecentTransaksi> recentTransaksi;

  DashboardSummary({
    required this.totalTransaksi,
    required this.proses,
    required this.accAkad,
    required this.akadBank,
    required this.batal,
    required this.totalUnit,
    required this.unitTersedia,
    required this.unitBooking,
    required this.unitTerjual,
    required this.totalBayarBulanIni,
    required this.cluster,
    required this.recentTransaksi,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final t = json['transaksi'] as Map<String, dynamic>? ?? {};
    final u = json['unit'] as Map<String, dynamic>? ?? {};
    final p = json['pembayaran_bulan_ini'] as Map<String, dynamic>? ?? {};
    final c = json['cluster'] as List<dynamic>? ?? [];
    final r = json['recent_transactions'] as List<dynamic>? ?? [];

    return DashboardSummary(
      totalTransaksi: _toInt(t['total_transaksi']),
      proses: _toInt(t['proses']),
      accAkad: _toInt(t['acc_akad']),
      akadBank: _toInt(t['akad_bank']),
      batal: _toInt(t['batal']),
      totalUnit: _toInt(u['total_unit']),
      unitTersedia: _toInt(u['tersedia']),
      unitBooking: _toInt(u['booking']),
      unitTerjual: _toInt(u['terjual']),
      totalBayarBulanIni: _toInt(p['total_bulan_ini']),
      cluster: c.map((e) => ClusterStat.fromJson(e as Map<String, dynamic>)).toList(),
      recentTransaksi: r
          .map((e) => RecentTransaksi.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static int _toInt(dynamic v) => v == null ? 0 : int.tryParse('$v') ?? 0;
}

class ClusterStat {
  final String clusterName;
  final int totalUnit;
  final int tersedia;
  final int booking;
  final int terjual;

  ClusterStat({
    required this.clusterName,
    required this.totalUnit,
    required this.tersedia,
    required this.booking,
    required this.terjual,
  });

  factory ClusterStat.fromJson(Map<String, dynamic> json) => ClusterStat(
        clusterName: json['cluster_name'] as String? ?? '',
        totalUnit: _toInt(json['total_unit']),
        tersedia: _toInt(json['tersedia']),
        booking: _toInt(json['booking']),
        terjual: _toInt(json['terjual']),
      );

  static int _toInt(dynamic v) => v == null ? 0 : int.tryParse('$v') ?? 0;
}

class RecentTransaksi {
  final int idTransaksi;
  final String tglBooking;
  final String nameLengkap;
  final String noBlok;
  final String clusterName;
  final String statusKonsumen;

  RecentTransaksi({
    required this.idTransaksi,
    required this.tglBooking,
    required this.nameLengkap,
    required this.noBlok,
    required this.clusterName,
    required this.statusKonsumen,
  });

  factory RecentTransaksi.fromJson(Map<String, dynamic> json) => RecentTransaksi(
        idTransaksi: int.tryParse('${json['id_transaksi']}') ?? 0,
        tglBooking: json['tgl_booking'] as String? ?? '',
        nameLengkap: json['name_lengkap'] as String? ?? '',
        noBlok: json['no_blok'] as String? ?? '',
        clusterName: json['cluster_name'] as String? ?? '',
        statusKonsumen: json['status_konsumen'] as String? ?? '',
      );
}