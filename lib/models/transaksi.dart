class Transaksi {
  final int idTransaksi;
  final String tglBooking;
  final String nameLengkap;
  final String noBlok;
  final String clusterName;
  final String tipeRumah;
  final int? luasTanah;
  final int? luasBangunan;
  final int? hargaJual;
  final String skemaBayar;
  final String skemaAkad;
  final String statusKonsumen;
  final String statusBank;
  final String? tanggalAkad;
  final String? deadlineBerkas;

  Transaksi({
    required this.idTransaksi,
    required this.tglBooking,
    required this.nameLengkap,
    required this.noBlok,
    required this.clusterName,
    required this.tipeRumah,
    this.luasTanah,
    this.luasBangunan,
    this.hargaJual,
    required this.skemaBayar,
    required this.skemaAkad,
    required this.statusKonsumen,
    this.statusBank = '',
    this.tanggalAkad,
    this.deadlineBerkas,
  });

  factory Transaksi.fromJson(Map<String, dynamic> json) => Transaksi(
        idTransaksi: int.tryParse('${json['id_transaksi']}') ?? 0,
        tglBooking: json['tgl_booking'] as String? ?? '',
        nameLengkap: json['name_lengkap'] as String? ?? '',
        noBlok: json['no_blok'] as String? ?? '',
        clusterName: json['cluster_name'] as String? ?? '',
        tipeRumah: json['tipe_rumah'] as String? ?? '',
        luasTanah: _toInt(json['luas_tanah']),
        luasBangunan: _toInt(json['luas_bangunan']),
        hargaJual: _toInt(json['harga_jual']),
        skemaBayar: json['skema_bayar'] as String? ?? '',
        skemaAkad: json['skema_akad'] as String? ?? '',
        statusKonsumen: json['status_konsumen'] as String? ?? '',
        statusBank: json['status_bank'] as String? ?? '',
        tanggalAkad: json['tanggal_akad'],
        deadlineBerkas: json['deadline_berkas'],
      );

  static int? _toInt(dynamic v) => v == null ? null : int.tryParse('$v');
}