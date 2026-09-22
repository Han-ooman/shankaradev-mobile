import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shandev_app/main.dart';
import 'package:shandev_app/utils/formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  test('Format rupiah', () {
    expect(formatRupiah(1000000), 'Rp 1.000.000');
    expect(formatRupiah(0), 'Rp 0');
  });

  test('Format tanggal', () {
    expect(formatTanggal('2026-09-22'), contains('Sep'));
    expect(formatTanggal('0000-00-00'), '-');
    expect(formatTanggal(null), '-');
  });

  testWidgets('App renders splash', (tester) async {
    await tester.pumpWidget(const ShandevApp());
    expect(find.text('Shankara Dev'), findsOneWidget);
  });
}