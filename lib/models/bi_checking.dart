class BiChecking {
  final int idBiChecking;
  final int idKonsumen;
  final String nameLengkap;
  final String? pekerjaan;
  final String? noWhatsapp;
  final String? noKtp;
  final String? alamatKtp;
  final int? idMarketing;
  final String? namaMarketing;
  final String tglCek;
  final String? lembaga;
  final String? noPengajuan;
  final String hasilBi;
  final String? catatan;
  final String createdAt;

  BiChecking({
    required this.idBiChecking,
    required this.idKonsumen,
    required this.nameLengkap,
    this.pekerjaan,
    this.noWhatsapp,
    this.noKtp,
    this.alamatKtp,
    this.idMarketing,
    this.namaMarketing,
    required this.tglCek,
    this.lembaga,
    this.noPengajuan,
    required this.hasilBi,
    this.catatan,
    required this.createdAt,
  });

  factory BiChecking.fromJson(Map<String, dynamic> json) => BiChecking(
        idBiChecking: int.tryParse('${json['id_bi_checking']}') ?? 0,
        idKonsumen: int.tryParse('${json['id_konsumen']}') ?? 0,
        nameLengkap: json['name_lengkap'] as String? ?? '',
        pekerjaan: json['pekerjaan'] as String?,
        noWhatsapp: json['no_whatsapp'] as String?,
        noKtp: json['no_ktp'] as String?,
        alamatKtp: json['alamat_ktp'] as String?,
        idMarketing: json['id_marketing'] != null ? int.tryParse('${json['id_marketing']}') : null,
        namaMarketing: json['nama_marketing'] as String?,
        tglCek: json['tgl_cek'] as String? ?? '',
        lembaga: json['lembaga'] as String?,
        noPengajuan: json['no_pengajuan'] as String?,
        hasilBi: json['hasil_bi'] as String? ?? 'Dalam Proses',
        catatan: json['catatan'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );

  static const List<String> hasilOptions = [
    'Dalam Proses',
    'Disetujui',
    'Ditolak',
    'Batal',
  ];
}