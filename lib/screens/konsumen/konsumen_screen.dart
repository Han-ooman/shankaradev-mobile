import 'package:flutter/material.dart';

import '../../models/konsumen.dart';
import '../../models/paginated.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import 'konsumen_detail_screen.dart';

class KonsumenScreen extends StatefulWidget {
  const KonsumenScreen({super.key});

  @override
  State<KonsumenScreen> createState() => _KonsumenScreenState();
}

class _KonsumenScreenState extends State<KonsumenScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _page = 1;
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';
  final List<Konsumen> _items = [];
  Paginated<Konsumen>? _meta;

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
      final res = await ApiService.instance.getKonsumen(search: _search.text.trim());
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
        _errorMsg = 'Gagal memuat konsumen';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _meta == null || !_meta!.hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.instance.getKonsumen(
        page: _page + 1,
        search: _search.text.trim(),
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
              hintText: 'Cari nama, KTP, atau WA',
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
    if (_items.isEmpty) return const Center(child: Text('Tidak ada data konsumen'));
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

  Widget _itemCard(Konsumen k) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => KonsumenDetailScreen(id: k.idKonsumen)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
                child: Text(
                  inisial(k.nameLengkap),
                  style: const TextStyle(
                    color: Color(0xFF1E3A8A),
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
                      k.nameLengkap,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    if (k.pekerjaan.isNotEmpty)
                      Text(
                        k.pekerjaan,
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    if (k.noWhatsapp.isNotEmpty)
                      Text(
                        k.noWhatsapp,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
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