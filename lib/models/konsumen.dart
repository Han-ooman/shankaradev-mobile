class Konsumen {
  final int idKonsumen;
  final String nameLengkap;
  final String noKtp;
  final String pekerjaan;
  final String noWhatsapp;
  final String alamatKtp;

  Konsumen({
    required this.idKonsumen,
    required this.nameLengkap,
    required this.noKtp,
    required this.pekerjaan,
    required this.noWhatsapp,
    required this.alamatKtp,
  });

  factory Konsumen.fromJson(Map<String, dynamic> json) => Konsumen(
        idKonsumen: int.tryParse('${json['id_konsumen']}') ?? 0,
        nameLengkap: json['name_lengkap'] as String? ?? '',
        noKtp: json['no_ktp'] as String? ?? '',
        pekerjaan: json['pekerjaan'] as String? ?? '',
        noWhatsapp: json['no_whatsapp'] as String? ?? '',
        alamatKtp: json['alamat_ktp'] as String? ?? '',
      );
}