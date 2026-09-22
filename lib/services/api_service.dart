import '../models/dashboard.dart';
import '../models/konsumen.dart';
import '../models/paginated.dart';
import '../models/rumah.dart';
import '../models/transaksi.dart';
import '../models/prospek.dart';
import '../models/bi_checking.dart';
import '../models/pembangunan.dart';
import '../models/pengaturan.dart';
import '../models/user.dart';
import 'api_client.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  Future<DashboardSummary> getDashboard() async {
    final res = await ApiClient.instance.get('/laporan/dashboard');
    return DashboardSummary.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<Paginated<Transaksi>> getTransaksi({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final res = await ApiClient.instance.get('/transaksi', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return Paginated.fromJson(res, Transaksi.fromJson);
  }

  Future<Transaksi> getTransaksiDetail(int id) async {
    final res = await ApiClient.instance.get('/transaksi/$id');
    return Transaksi.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<Paginated<Rumah>> getRumah({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
  }) async {
    final res = await ApiClient.instance.get('/rumah', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status_unit': status,
    });
    return Paginated.fromJson(res, Rumah.fromJson);
  }

  Future<Rumah> getRumahDetail(int id) async {
    final res = await ApiClient.instance.get('/rumah/$id');
    return Rumah.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<Paginated<Konsumen>> getKonsumen({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final res = await ApiClient.instance.get('/konsumen', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return Paginated.fromJson(res, Konsumen.fromJson);
  }

  Future<Konsumen> getKonsumenDetail(int id) async {
    final res = await ApiClient.instance.get('/konsumen/$id');
    return Konsumen.fromJson(res['data'] as Map<String, dynamic>);
  }

  // ===== PROSPEK =====
  Future<Paginated<Prospek>> getProspek({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    String? sumber,
  }) async {
    final res = await ApiClient.instance.get('/prospek', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (sumber != null && sumber.isNotEmpty) 'sumber': sumber,
    });
    return Paginated.fromJson(res, Prospek.fromJson);
  }

  Future<Prospek> getProspekDetail(int id) async {
    final res = await ApiClient.instance.get('/prospek/$id');
    return Prospek.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<Prospek> dealProspek(int id) async {
    final res = await ApiClient.instance.post('/prospek/$id/deal', {});
    return Prospek.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getProspekStats() async {
    final res = await ApiClient.instance.get('/prospek/stats');
    return List<Map<String, dynamic>>.from(res['data']);
  }

  // ===== BI CHECKING =====
  Future<Paginated<BiChecking>> getBiChecking({
    int page = 1,
    int perPage = 20,
    String? search,
    String? hasil,
    int? marketingId,
  }) async {
    final res = await ApiClient.instance.get('/bi-checking', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (hasil != null && hasil.isNotEmpty) 'hasil': hasil,
      if (marketingId != null) 'marketing_id': marketingId,
    });
    return Paginated.fromJson(res, BiChecking.fromJson);
  }

  Future<BiChecking> getBiCheckingDetail(int id) async {
    final res = await ApiClient.instance.get('/bi-checking/$id');
    return BiChecking.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getBiCheckingOptions() async {
    final res = await ApiClient.instance.get('/bi-checking/options');
    return res['data'] as Map<String, dynamic>;
  }

  Future<BiChecking> createBiChecking(Map<String, dynamic> data) async {
    final res = await ApiClient.instance.post('/bi-checking', data);
    return BiChecking.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> updateBiChecking(int id, Map<String, dynamic> data) async {
    await ApiClient.instance.put('/bi-checking/$id', data);
  }

  Future<void> deleteBiChecking(int id) async {
    await ApiClient.instance.post('/bi-checking/$id', {}, allowRefresh: false); // DELETE via POST for simplicity
  }

  Future<List<Map<String, dynamic>>> getBiCheckingStats() async {
    final res = await ApiClient.instance.get('/bi-checking/stats');
    return List<Map<String, dynamic>>.from(res['data']);
  }

  // ===== PEMBANGUNAN (PROGRES) =====
  Future<Paginated<Pembangunan>> getPembangunan({
    int page = 1,
    int perPage = 20,
    String? search,
    String? status,
    int? clusterId,
  }) async {
    final res = await ApiClient.instance.get('/pembangunan', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
      if (status != null && status.isNotEmpty) 'status': status,
      if (clusterId != null) 'cluster_id': clusterId,
    });
    return Paginated.fromJson(res, Pembangunan.fromJson);
  }

  Future<Pembangunan> getPembangunanDetail(int id) async {
    final res = await ApiClient.instance.get('/pembangunan/$id');
    return Pembangunan.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<Pembangunan> createPembangunan(Map<String, dynamic> data) async {
    final res = await ApiClient.instance.post('/pembangunan', data);
    return Pembangunan.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> updatePembangunan(int id, Map<String, dynamic> data) async {
    await ApiClient.instance.put('/pembangunan/$id', data);
  }

  Future<void> deletePembangunan(int id) async {
    await ApiClient.instance.post('/pembangunan/$id', {}, allowRefresh: false);
  }

  Future<List<Map<String, dynamic>>> getPembangunanStats() async {
    final res = await ApiClient.instance.get('/pembangunan/stats');
    return List<Map<String, dynamic>>.from(res['data']);
  }

  Future<List<Map<String, dynamic>>> getPembangunanUnits() async {
    final res = await ApiClient.instance.get('/pembangunan/units');
    return List<Map<String, dynamic>>.from(res['data']);
  }

  // ===== PENGATURAN (AKUN & SISTEM) =====
  Future<PengaturanSistem> getPengaturan() async {
    final res = await ApiClient.instance.get('/pengaturan');
    return PengaturanSistem.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> updatePengaturan(PengaturanSistem data) async {
    await ApiClient.instance.put('/pengaturan', data.toJson());
  }

  Future<Paginated<User>> getUsers({
    int page = 1,
    int perPage = 20,
    String? search,
  }) async {
    final res = await ApiClient.instance.get('/pengaturan/users', {
      'page': page,
      'per_page': perPage,
      if (search != null && search.isNotEmpty) 'search': search,
    });
    return Paginated.fromJson(res, User.fromJson);
  }

  Future<User> getUserDetail(int id) async {
    final res = await ApiClient.instance.get('/pengaturan/users/$id');
    return User.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final res = await ApiClient.instance.post('/pengaturan/users', data);
    return User.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    await ApiClient.instance.put('/pengaturan/users/$id', data);
  }

  Future<void> deleteUser(int id) async {
    await ApiClient.instance.post('/pengaturan/users/$id', {}, allowRefresh: false);
  }

  Future<List<String>> getUserRoles() async {
    final res = await ApiClient.instance.get('/pengaturan/users/roles');
    return List<String>.from(res['data']);
  }
}