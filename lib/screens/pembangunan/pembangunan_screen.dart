import 'package:flutter/material.dart';

import '../../models/paginated.dart';
import '../../models/pembangunan.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';
import 'pembangunan_detail_screen.dart';

class PembangunanScreen extends StatefulWidget {
  const PembangunanScreen({super.key});

  @override
  State<PembangunanScreen> createState() => _PembangunanScreenState();
}

class _PembangunanScreenState extends State<PembangunanScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _page = 1;
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';
  String? _statusFilter;
  int? _clusterFilter;
  final List<Pembangunan> _items = [];
  Paginated<Pembangunan>? _meta;

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
      final res = await ApiService.instance.getPembangunan(
        search: _search.text.trim(),
        status: _statusFilter,
        clusterId: _clusterFilter,
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
        _errorMsg = 'Gagal memuat data pembangunan';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _meta == null || !_meta!.hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.instance.getPembangunan(
        page: _page + 1,
        search: _search.text.trim(),
        status: _statusFilter,
        clusterId: _clusterFilter,
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
          child: Column(
            children: [
              TextField(
                controller: _search,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _load(),
                decoration: InputDecoration(
                  hintText: 'Cari blok, cluster, tipe, atau konsumen',
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterChip('Semua Status', null),
                          for (final s in Pembangunan.statusOptions) _filterChip(s, s),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _filterChip(String label, String? value) {
    final selected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          _load();
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_error) return _errorView();
    if (_loading && _items.isEmpty) return const Center(child: CircularProgressIndicator());
    if (_items.isEmpty) return const Center(child: Text('Tidak ada data progres pembangunan'));
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

  Widget _itemCard(Pembangunan p) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PembangunanDetailScreen(id: p.idPembangunan)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFD97706).withValues(alpha: 0.12),
                    child: Text(
                      inisial(p.clusterName),
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${p.clusterName} - Blok ${p.noBlok}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tipe: ${p.tipeRumah}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        if (p.nameLengkap != null && p.nameLengkap!.isNotEmpty)
                          Text(
                            'Konsumen: ${p.nameLengkap}',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: p.persentaseProgres / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(_progressColor(p.statusPembangunan)),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${p.persentaseProgres}%  •  ${p.statusPembangunan}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  StatusChip(label: p.statusPembangunan, status: p.statusPembangunan, compact: true),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _progressColor(String status) {
    switch (status) {
      case 'Selesai':
        return const Color(0xFF059669);
      case 'Finishing':
        return const Color(0xFF7C3AED);
      case 'Struktur':
        return const Color(0xFF2563EB);
      case 'Pondasi':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }
}