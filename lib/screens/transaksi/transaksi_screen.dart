import 'package:flutter/material.dart';

import '../../models/paginated.dart';
import '../../models/transaksi.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/status_chip.dart';
import 'transaksi_detail_screen.dart';

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  int _page = 1;
  bool _loading = false;
  bool _error = false;
  String _errorMsg = '';
  final List<Transaksi> _items = [];
  Paginated<Transaksi>? _meta;

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
      final res = await ApiService.instance.getTransaksi(search: _search.text.trim());
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
        _errorMsg = 'Gagal memuat transaksi';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _meta == null || !_meta!.hasMore) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.instance.getTransaksi(
        page: _page + 1,
        search: _search.text.trim(),
      );
      setState(() {
        _page++;
        _items.addAll(res.items);
        _meta = res;
      });
    } catch (_) {
      // abaikan gagal load more
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await _load();
    if (_scroll.hasClients && _scroll.offset > 0) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
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
              hintText: 'Cari nama, blok, atau no transaksi',
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
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_error) {
      return _errorView();
    }
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return const Center(child: Text('Tidak ada data transaksi'));
    }
    return RefreshIndicator(
      onRefresh: _refresh,
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

  Widget _itemCard(Transaksi t) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TransaksiDetailScreen(id: t.idTransaksi)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'TRX #${t.idTransaksi}',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusChip(label: t.statusKonsumen, status: t.statusKonsumen),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                t.nameLengkap,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.home_outlined, size: 15, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('${t.noBlok} · ${t.clusterName}', style: const TextStyle(fontSize: 13, color: Colors.black87)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text('Booking: ${formatTanggal(t.tglBooking)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Text(formatRupiah(t.hargaJual), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}