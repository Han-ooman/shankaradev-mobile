import 'package:intl/intl.dart';

String formatRupiah(dynamic value) {
  final n = value == null ? 0 : (value is int ? value : int.tryParse('$value') ?? 0);
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(n);
}

String formatTanggal(String? tanggal) {
  if (tanggal == null || tanggal.isEmpty || tanggal == '0000-00-00') return '-';
  final t = tanggal.contains(' ') ? tanggal.split(' ').first : tanggal;
  try {
    final d = DateTime.parse(t);
    return DateFormat('dd MMM yyyy', 'id_ID').format(d);
  } catch (_) {
    return t;
  }
}

String inisial(String name) {
  if (name.isEmpty) return '?';
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

String statusUnitLabel(String status) {
  switch (status) {
    case 'tersedia':
      return 'Tersedia';
    case 'booking':
      return 'Booking';
    case 'terjual':
      return 'Terjual';
    default:
      return status;
  }
}