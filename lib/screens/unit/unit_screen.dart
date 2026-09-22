import 'package:flutter/material.dart';

import '../../models/paginated.dart';
import '../../models/rumah.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'unit_detail_screen.dart';

class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _page = 1;
  String _status = '';
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';
  final List<Rumah> _items = [];
  Paginated<Rumah>? _meta;

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
      final res = await ApiService.instance.getRumah(
        search: _search.text.trim(),
        status: _status,
      );
      setState(() {
        _items
          ..clear()
          ..addAll(res.items);
        _meta = res;
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
        _errorMsg = 'Gagal memuat unit';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _meta == null || !_meta!.hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.instance.getRumah(
        page: _page + 1,
        search: _search.text.trim(),
        status: _status,
      );
      setState(() {
        _page++;
        _items.addAll(res.items);
        _meta = res;
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
              hintText: 'Cari blok atau tipe rumah',
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
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _filterChip('Semua', ''),
              _filterChip('Tersedia', 'tersedia'),
              _filterChip('Booking', 'booking'),
              _filterChip('Terjual', 'terjual'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final selected = _status == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        selectedColor: const Color(0xFF1E3A8A),
        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        onSelected: (_) {
          setState(() => _status = value);
          _load();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_error) return _errorView();
    if (_loading && _items.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('Tidak ada data unit'));
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

  Widget _itemCard(Rumah r) {
    final color = switch (r.statusUnit) {
      'tersedia' => const Color(0xFF2563EB),
      'booking' => const Color(0xFFD97706),
      'terjual' => const Color(0xFF059669),
      _ => const Color(0xFF6B7280),
    };
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => UnitDetailScreen(id: r.idRumah)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home_outlined, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              r.noBlok,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              statusUnitLabel(r.statusUnit),
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${r.clusterName} · ${r.tipeRumah}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    formatRupiah(r.hargaJual),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}