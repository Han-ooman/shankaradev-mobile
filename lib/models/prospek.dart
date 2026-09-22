class Prospek {
  final int idProspek;
  final String nameLengkap;
  final String noKtp;
  final String pekerjaan;
  final String noWhatsapp;
  final String sumber;
  final String clusterMinat;
  final String unitMinat;
  final String catatan;
  final String statusFollowup;
  final String? tanggalFollowup;
  final String createdAt;
  final String updatedAt;

  Prospek({
    required this.idProspek,
    required this.nameLengkap,
    required this.noKtp,
    required this.pekerjaan,
    required this.noWhatsapp,
    required this.sumber,
    required this.clusterMinat,
    required this.unitMinat,
    required this.catatan,
    required this.statusFollowup,
    this.tanggalFollowup,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Prospek.fromJson(Map<String, dynamic> json) => Prospek(
        idProspek: int.tryParse('${json['id_prospek']}') ?? 0,
        nameLengkap: json['name_lengkap'] as String? ?? '',
        noKtp: json['no_ktp'] as String? ?? '',
        pekerjaan: json['pekerjaan'] as String? ?? '',
        noWhatsapp: json['no_whatsapp'] as String? ?? '',
        sumber: json['sumber'] as String? ?? 'Lainnya',
        clusterMinat: json['cluster_minat'] as String? ?? '',
        unitMinat: json['unit_minat'] as String? ?? '',
        catatan: json['catatan'] as String? ?? '',
        statusFollowup: json['status_followup'] as String? ?? 'Baru',
        tanggalFollowup: json['tanggal_followup'] as String?,
        createdAt: json['created_at'] as String? ?? '',
        updatedAt: json['updated_at'] as String? ?? '',
      );

  static const List<String> statusOptions = [
    'Baru',
    'Sudah Dihubungi',
    'Minat',
    'Sudah Survey',
    'Deal',
    'Tidak Lanjut',
  ];

  static const List<String> sumberOptions = [
    'Pameran',
    'Walk-in Kantor',
    'Instagram',
    'Facebook',
    'WhatsApp',
    'Referensi',
    'Lainnya',
  ];
}