import 'package:flutter/material.dart';

import '../../models/paginated.dart';
import '../../services/api_client.dart';
import '../../utils/formatters.dart';
import 'tipe_rumah_detail_screen.dart';

class TipeRumahScreen extends StatefulWidget {
  const TipeRumahScreen({super.key});

  @override
  State<TipeRumahScreen> createState() => _TipeRumahScreenState();
}

class _TipeRumahScreenState extends State<TipeRumahScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _page = 1;
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';
  final List<TipeRumahItem> _items = [];
  Paginated<dynamic>? _meta;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_meta == null || !_meta!.hasMore) return;
    if (_scroll.position.extentAfter < 300) _loadMore();
  }

  Future<void> _load() async {
    setState(() {
      _page = 1;
      _loading = true;
      _error = false;
    });
    try {
      final res = await ApiClient.instance.get('/tipe-rumah', {
        'page': _page,
        'per_page': 20,
        'search': _search.text.trim(),
      });
      setState(() {
        _items
          ..clear()
          ..addAll((res['data']['items'] as List)
              .map((e) => TipeRumahItem.fromJson(e as Map<String, dynamic>))
              .toList());
        _meta = Paginated(
          items: (res['data']['items'] as List)
              .map((e) => TipeRumahItem.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: int.tryParse('${res['data']['pagination']['total']}') ?? 0,
          perPage: int.tryParse('${res['data']['pagination']['per_page']}') ?? 20,
          currentPage: int.tryParse('${res['data']['pagination']['current_page']}') ?? 1,
          lastPage: int.tryParse('${res['data']['pagination']['last_page']}') ?? 1,
        );
        _loading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = true;
        _errorMsg = e.message;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _errorMsg = 'Gagal memuat tipe rumah';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _meta == null || !_meta!.hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/tipe-rumah', {
        'page': _page + 1,
        'per_page': 20,
        'search': _search.text.trim(),
      });
      setState(() {
        _page++;
        _items.addAll((res['data']['items'] as List)
            .map((e) => TipeRumahItem.fromJson(e as Map<String, dynamic>))
            .toList());
        _meta = Paginated(
          items: (res['data']['items'] as List)
              .map((e) => TipeRumahItem.fromJson(e as Map<String, dynamic>))
              .toList(),
          total: int.tryParse('${res['data']['pagination']['total']}') ?? 0,
          perPage: int.tryParse('${res['data']['pagination']['per_page']}') ?? 20,
          currentPage: int.tryParse('${res['data']['pagination']['current_page']}') ?? 1,
          lastPage: int.tryParse('${res['data']['pagination']['last_page']}') ?? 1,
        );
      });
    } catch (_) {
      // abaikan
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _load(),
            decoration: InputDecoration(
              hintText: 'Cari tipe rumah / keterangan',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _search.clear();
                        _load();
                      },
                    )
                  : null,
            ),
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_error) return _errorView();
    if (_loading && _items.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('Tidak ada data tipe rumah'));
    return RefreshIndicator(
      onRefresh: () async => _load(),
      child: ListView.separated(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const SizedBox.shrink();
          }
          return _itemCard(_items[index]);
        },
      ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 52, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_errorMsg, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Muat Ulang')),
        ],
      ),
    );
  }

  Widget _itemCard(TipeRumahItem t) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TipeRumahDetailScreen(id: t.idTipe)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                child: const Icon(Icons.home_outlined, color: Color(0xFF1E3A8A), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.tipeRumah,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Harga: ${formatRupiah(t.harga)}',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    Text(
                      'DP ${t.dpPersen.toStringAsFixed(2)}% (${formatRupiah(t.dpNominal)})  •  Angsuran: ${formatRupiah(t.angsuran)}/${t.tenorBulan} bln',
                      style: const TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

class TipeRumahItem {
  final int idTipe;
  final String tipeRumah;
  final int harga;
  final double dpPersen;
  final int dpNominal;
  final int angsuran;
  final int tenorBulan;
  final String? persyaratan;
  final String? keterangan;
  final String createdAt;

  TipeRumahItem({
    required this.idTipe,
    required this.tipeRumah,
    required this.harga,
    required this.dpPersen,
    required this.dpNominal,
    required this.angsuran,
    required this.tenorBulan,
    this.persyaratan,
    this.keterangan,
    required this.createdAt,
  });

  factory TipeRumahItem.fromJson(Map<String, dynamic> json) => TipeRumahItem(
        idTipe: int.tryParse('${json['id_tipe']}') ?? 0,
        tipeRumah: json['tipe_rumah'] as String? ?? '',
        harga: int.tryParse('${json['harga']}') ?? 0,
        dpPersen: (json['dp_persen'] as num?)?.toDouble() ?? 0.0,
        dpNominal: int.tryParse('${json['dp_nominal']}') ?? 0,
        angsuran: int.tryParse('${json['angsuran']}') ?? 0,
        tenorBulan: int.tryParse('${json['tenor_bulan']}') ?? 0,
        persyaratan: json['persyaratan'] as String?,
        keterangan: json['keterangan'] as String?,
        createdAt: json['created_at'] as String? ?? '',
      );
}