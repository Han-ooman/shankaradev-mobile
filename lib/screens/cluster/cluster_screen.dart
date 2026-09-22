import 'package:flutter/material.dart';

import '../../models/dashboard.dart';
import '../../models/paginated.dart';
import '../../services/api_client.dart';

class ClusterScreen extends StatefulWidget {
  const ClusterScreen({super.key});

  @override
  State<ClusterScreen> createState() => _ClusterScreenState();
}

class _ClusterScreenState extends State<ClusterScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _page = 1;
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';
  final List<ClusterStat> _items = [];
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
      final res = await ApiClient.instance.get('/clusters', {
        'page': _page,
        'per_page': 20,
        'search': _search.text.trim(),
      });
      setState(() {
        _items
          ..clear()
          ..addAll((res['data']['items'] as List)
              .map((e) => ClusterStat.fromJson(e as Map<String, dynamic>))
              .toList());
        _meta = Paginated(
          items: (res['data']['items'] as List)
              .map((e) => ClusterStat.fromJson(e as Map<String, dynamic>))
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
        _errorMsg = 'Gagal memuat cluster';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _meta == null || !_meta!.hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ApiClient.instance.get('/clusters', {
        'page': _page + 1,
        'per_page': 20,
        'search': _search.text.trim(),
      });
      setState(() {
        _page++;
        _items.addAll((res['data']['items'] as List)
            .map((e) => ClusterStat.fromJson(e as Map<String, dynamic>))
            .toList());
        _meta = Paginated(
          items: (res['data']['items'] as List)
              .map((e) => ClusterStat.fromJson(e as Map<String, dynamic>))
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
              hintText: 'Cari nama cluster / lokasi',
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
    if (_items.isEmpty) return const Center(child: Text('Tidak ada data cluster'));
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

  Widget _itemCard(ClusterStat c) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          // TODO: navigasi ke detail cluster (daftar unit per cluster)
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    child: const Icon(Icons.business_outlined, color: Color(0xFF2563EB), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.clusterName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total Unit: ${c.totalUnit}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _dot('${c.tersedia}', const Color(0xFF2563EB), 'Tersedia'),
                  _dot('${c.booking}', const Color(0xFFD97706), 'Booking'),
                  _dot('${c.terjual}', const Color(0xFF059669), 'Terjual'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(String value, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text('$value $label', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}