class User {
  final int id;
  final String username;
  final String namaLengkap;
  final String role;
  final String? status;

  User({
    required this.id,
    required this.username,
    required this.namaLengkap,
    required this.role,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: int.tryParse('${json['id']}') ?? 0,
        username: json['username'] as String? ?? '',
        namaLengkap: json['nama_lengkap'] as String? ?? '',
        role: json['role'] as String? ?? '',
        status: json['status'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'nama_lengkap': namaLengkap,
        'role': role,
        if (status != null) 'status': status,
      };
}