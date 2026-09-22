class Rumah {
  final int idRumah;
  final String noBlok;
  final int idCluster;
  final String clusterName;
  final String tipeRumah;
  final int? luasTanah;
  final int? luasBangunan;
  final int? hargaJual;
  final String statusUnit;
  final String noShm;

  Rumah({
    required this.idRumah,
    required this.noBlok,
    required this.idCluster,
    required this.clusterName,
    required this.tipeRumah,
    this.luasTanah,
    this.luasBangunan,
    this.hargaJual,
    required this.statusUnit,
    this.noShm = '',
  });

  factory Rumah.fromJson(Map<String, dynamic> json) => Rumah(
        idRumah: int.tryParse('${json['id_rumah']}') ?? 0,
        noBlok: json['no_blok'] as String? ?? '',
        idCluster: int.tryParse('${json['id_cluster']}') ?? 0,
        clusterName: json['cluster_name'] as String? ?? '',
        tipeRumah: json['tipe_rumah'] as String? ?? '',
        luasTanah: _toInt(json['luas_tanah']),
        luasBangunan: _toInt(json['luas_bangunan']),
        hargaJual: _toInt(json['harga_jual']),
        statusUnit: json['status_unit'] as String? ?? '',
        noShm: json['no_shm'] as String? ?? '',
      );

  static int? _toInt(dynamic v) => v == null ? null : int.tryParse('$v');
}