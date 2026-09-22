class Pembangunan {
  final int idPembangunan;
  final int idRumah;
  final String noBlok;
  final String tipeRumah;
  final String clusterName;
  final String? nameLengkap;
  final int persentaseProgres;
  final String statusPembangunan;
  final String? tglMulai;
  final String? tglTargetSelesai;
  final String? catatanLapangan;
  final String createdAt;
  final String updatedAt;

  Pembangunan({
    required this.idPembangunan,
    required this.idRumah,
    required this.noBlok,
    required this.tipeRumah,
    required this.clusterName,
    this.nameLengkap,
    required this.persentaseProgres,
    required this.statusPembangunan,
    this.tglMulai,
    this.tglTargetSelesai,
    this.catatanLapangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pembangunan.fromJson(Map<String, dynamic> json) => Pembangunan(
        idPembangunan: int.tryParse('${json['id_pembangunan']}') ?? 0,
        idRumah: int.tryParse('${json['id_rumah']}') ?? 0,
        noBlok: json['no_blok'] as String? ?? '',
        tipeRumah: json['tipe_rumah'] as String? ?? '',
        clusterName: json['cluster_name'] as String? ?? '',
        nameLengkap: json['name_lengkap'] as String?,
        persentaseProgres: int.tryParse('${json['persentase_progres']}') ?? 0,
        statusPembangunan: json['status_pembangunan'] as String? ?? 'Persiapan',
        tglMulai: json['tgl_mulai'] as String?,
        tglTargetSelesai: json['tgl_target_selesai'] as String?,
        catatanLapangan: json['catatan_lapangan'] as String?,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  static const List<String> statusOptions = [
    'Persiapan',
    'Pondasi',
    'Struktur',
    'Finishing',
    'Selesai',
  ];
}