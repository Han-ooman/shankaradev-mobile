class PengaturanSistem {
  final String namaPerusahaan;
  final String pimpinanPerusahaan;
  final String teleponPerusahaan;
  final String emailPerusahaan;
  final String rekeningPerusahaan;
  final String alamatPerusahaan;
  final String masterBank;

  PengaturanSistem({
    required this.namaPerusahaan,
    required this.pimpinanPerusahaan,
    required this.teleponPerusahaan,
    required this.emailPerusahaan,
    required this.rekeningPerusahaan,
    required this.alamatPerusahaan,
    required this.masterBank,
  });

  factory PengaturanSistem.fromJson(Map<String, dynamic> json) => PengaturanSistem(
        namaPerusahaan: json['nama_perusahaan'] as String? ?? '',
        pimpinanPerusahaan: json['pimpinan_perusahaan'] as String? ?? '',
        teleponPerusahaan: json['telepon_perusahaan'] as String? ?? '',
        emailPerusahaan: json['email_perusahaan'] as String? ?? '',
        rekeningPerusahaan: json['rekening_perusahaan'] as String? ?? '',
        alamatPerusahaan: json['alamat_perusahaan'] as String? ?? '',
        masterBank: json['master_bank'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'nama_perusahaan': namaPerusahaan,
        'pimpinan_perusahaan': pimpinanPerusahaan,
        'telepon_perusahaan': teleponPerusahaan,
        'email_perusahaan': emailPerusahaan,
        'rekening_perusahaan': rekeningPerusahaan,
        'alamat_perusahaan': alamatPerusahaan,
        'master_bank': masterBank,
      };
}