import '../models/dashboard.dart';
import '../models/konsumen.dart';
import '../models/paginated.dart';
import '../models/rumah.dart';
import '../models/transaksi.dart';
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
}