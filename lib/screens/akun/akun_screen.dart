import 'package:flutter/material.dart';

import '../../models/paginated.dart';
import '../../models/user.dart';
import '../../services/api_client.dart';
import '../../services/api_service.dart';
import '../../utils/formatters.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({super.key});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Profil Perusahaan
  final _namaPerusahaan = TextEditingController();
  final _pimpinanPerusahaan = TextEditingController();
  final _teleponPerusahaan = TextEditingController();
  final _emailPerusahaan = TextEditingController();
  final _rekeningPerusahaan = TextEditingController();
  final _alamatPerusahaan = TextEditingController();
  final _masterBank = TextEditingController();
  bool _loadingProfil = false;

  // Manajemen User
  final _userSearch = TextEditingController();
  final _userScroll = ScrollController();
  int _userPage = 1;
  bool _userLoading = false;
  bool _userError = false;
  String _userErrorMsg = '';
  final List<User> _users = [];
  Paginated<User>? _userMeta;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfil();
    _loadUsers();
    _userScroll.addListener(_onUserScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearch.dispose();
    _userScroll.dispose();
    _namaPerusahaan.dispose();
    _pimpinanPerusahaan.dispose();
    _teleponPerusahaan.dispose();
    _emailPerusahaan.dispose();
    _rekeningPerusahaan.dispose();
    _alamatPerusahaan.dispose();
    _masterBank.dispose()
    ;
    super.dispose();
  }

  void _onUserScroll() {
    if (_userMeta == null || !_userMeta!.hasMore) return;
    if (_userScroll.position.extentAfter < 300) _loadMoreUsers();
  }

  Future<void> _loadProfil() async {
    setState(() => _loadingProfil = true);
    try {
      final res = await ApiClient.instance.get('/pengaturan');
      final data = res['data'] as Map<String, dynamic>;
      _namaPerusahaan.text = data['nama_perusahaan'] as String? ?? '';
      _pimpinanPerusahaan.text = data['pimpinan_perusahaan'] as String? ?? '';
      _teleponPerusahaan.text = data['telepon_perusahaan'] as String? ?? '';
      _emailPerusahaan.text = data['email_perusahaan'] as String? ?? '';
      _rekeningPerusahaan.text = data['rekening_perusahaan'] as String? ?? '';
      _alamatPerusahaan.text = data['alamat_perusahaan'] as String? ?? '';
      _masterBank.text = data['master_bank'] as String? ?? '';
    } catch (_) {
      // abaikan
    } finally {
      if (mounted) setState(() => _loadingProfil = false);
    }
  }

  Future<void> _saveProfil() async {
    setState(() => _loadingProfil = true);
    try {
      await ApiClient.instance.put('/pengaturan', {
        'nama_perusahaan': _namaPerusahaan.text,
        'pimpinan_perusahaan': _pimpinanPerusahaan.text,
        'telepon_perusahaan': _teleponPerusahaan.text,
        'email_perusahaan': _emailPerusahaan.text,
        'rekening_perusahaan': _rekeningPerusahaan.text,
        'alamat_perusahaan': _alamatPerusahaan.text,
        'master_bank': _masterBank.text,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil perusahaan disimpan')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingProfil = false);
    }
  }

  Future<void> _loadUsers() async {
    setState(() {
      _userPage = 1;
      _userLoading = true;
      _userError = false;
    });
    try {
      final res = await ApiService.instance.getUsers(
        search: _userSearch.text.trim(),
      );
      setState(() {
        _users
          ..clear()
          ..addAll(res.items);
        _userMeta = res;
        _userLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _userError = true;
        _userErrorMsg = e.message;
        _userLoading = false;
      });
    } catch (_) {
      setState(() {
        _userError = true;
        _userErrorMsg = 'Gagal memuat user';
        _userLoading = false;
      });
    }
  }

  Future<void> _loadMoreUsers() async {
    if (_userLoading || _userMeta == null || !_userMeta!.hasMore) return;
    setState(() => _userLoading = true);
    try {
      final res = await ApiService.instance.getUsers(
        page: _userPage + 1,
        search: _userSearch.text.trim(),
      );
      setState(() {
        _userPage++;
        _users.addAll(res.items);
        _userMeta = res;
      });
    } catch (_) {
      // abaikan
    } finally {
      if (mounted) setState(() => _userLoading = false);
    }
  }

  Future<void> _showUserDialog({User? user}) async {
    final isEdit = user != null;
    final namaCtrl = TextEditingController(text: user?.namaLengkap ?? '');
    final usernameCtrl = TextEditingController(text: user?.username ?? '');
    final passwordCtrl = TextEditingController();
    String role = user?.role ?? 'Marketing';
    String status = user?.status ?? 'Aktif';
    List<String> roles;
    try {
      roles = await ApiService.instance.getUserRoles();
    } catch (_) {
      roles = const ['Super Admin', 'Admin', 'Marketing', 'Pengawas Lapangan', 'Kasir Keuangan', 'Admin Pemberkasan'];
    }
    if (!roles.contains(role)) roles = [...roles, role];
    if (!mounted) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit User' : 'Tambah User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: namaCtrl,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameCtrl,
                enabled: !isEdit, // username tidak bisa diubah saat edit
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: isEdit ? 'Password Baru (kosongkan = tidak ubah)' : 'Password',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: role,
                items: ['Super Admin', 'Admin', 'Marketing', 'Pengawas Lapangan', 'Kasir Keuangan', 'Admin Pemberkasan']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: status,
                items: ['Aktif', 'Nonaktif']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => status = v!,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      if (user == null) {
        await ApiService.instance.createUser({
          'nama_lengkap': namaCtrl.text,
          'username': usernameCtrl.text,
          'password': passwordCtrl.text,
          'role': role,
          'status': status,
        });
      } else {
        final data = <String, dynamic>{
          'nama_lengkap': namaCtrl.text,
          'role': role,
          'status': status,
        };
        if (passwordCtrl.text.isNotEmpty) {
          data['password'] = passwordCtrl.text;
        }
        await ApiService.instance.updateUser(user.id, data);
      }
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(user == null ? 'User ditambahkan' : 'User diperbarui')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  Future<void> _deleteUser(User user) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus User'),
        content: Text('Yakin ingin menghapus user "${user.namaLengkap}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      await ApiService.instance.deleteUser(user.id);
      await _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User dihapus')),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Akun'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.business), text: 'Profil Perusahaan'),
            Tab(icon: Icon(Icons.people), text: 'Manajemen User'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfilTab(),
          _buildUserTab(),
        ],
      ),
    );
  }

  Widget _buildProfilTab() {
    if (_loadingProfil) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Profil Perusahaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(
                  controller: _namaPerusahaan,
                  decoration: const InputDecoration(labelText: 'Nama Perusahaan'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pimpinanPerusahaan,
                  decoration: const InputDecoration(labelText: 'Pimpinan Perusahaan'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _teleponPerusahaan,
                  decoration: const InputDecoration(labelText: 'Telepon'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailPerusahaan,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _rekeningPerusahaan,
                  decoration: const InputDecoration(labelText: 'Rekening Perusahaan'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _alamatPerusahaan,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Alamat Perusahaan'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _masterBank,
                  decoration: const InputDecoration(labelText: 'Master Bank (pilihan bank untuk DP)'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadingProfil ? null : _saveProfil,
                  icon: _loadingProfil
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save),
                  label: const Text('Simpan Profil'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _userSearch,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _loadUsers(),
                  decoration: InputDecoration(
                    hintText: 'Cari nama / username / role',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _userSearch.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _userSearch.clear();
                              _loadUsers();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => _showUserDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Tambah'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _userError
              ? _userErrorView()
              : _userLoading && _users.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(child: Text('Tidak ada data user'))
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.separated(
                            controller: _userScroll,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: _users.length + 1,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              if (index == _users.length) {
                                return _userLoading
                                    ? const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      )
                                    : const SizedBox.shrink();
                              }
                              return _userCard(_users[index]);
                            },
                          ),
                        ),
                      ),
      ],
    );
  }

  Widget _userErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 52, color: Colors.grey),
          const SizedBox(height: 12),
          Text(_userErrorMsg, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          OutlinedButton.icon(onPressed: _loadUsers, icon: const Icon(Icons.refresh), label: const Text('Muat Ulang')),
        ],
      ),
    );
  }

  Widget _userCard(User u) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.12),
          child: Text(
            inisial(u.namaLengkap),
            style: const TextStyle(color: Color(0xFF1E3A8A), fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(u.namaLengkap, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${u.username}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 2),
            Wrap(
              spacing: 4,
              children: [
                Chip(label: Text(u.role, style: const TextStyle(fontSize: 10)), visualDensity: VisualDensity.compact),
                Chip(
                  label: Text(u.status ?? 'Aktif', style: const TextStyle(fontSize: 10)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: (u.status == 'Aktif') ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _showUserDialog(user: _users[_users.indexWhere((e) => e.id == u.id)]),
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteUser(u),
              tooltip: 'Hapus',
            ),
          ],
        ),
        onTap: () => _showUserDialog(user: u),
      ),
    );
  }
}