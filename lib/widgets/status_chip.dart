import 'package:flutter/material.dart';

Color statusColor(String status) {
  final s = status.toUpperCase();
  if (s.contains('BATAL')) return const Color(0xFFDC2626);
  if (s.contains('AKAD BANK')) return const Color(0xFF7C3AED);
  if (s.contains('ACC')) return const Color(0xFF059669);
  if (s.contains('PROSES')) return const Color(0xFFD97706);
  if (s == 'TERJUAL' || s.contains('TERSEDIA') == false && s == 'TERJUAL') {
    return const Color(0xFF059669);
  }
  if (s == 'TERSEDIA') return const Color(0xFF2563EB);
  if (s == 'BOOKING') return const Color(0xFFD97706);
  return const Color(0xFF6B7280);
}

class StatusChip extends StatelessWidget {
  final String label;
  final String status;
  final bool compact;

  const StatusChip({
    super.key,
    required this.label,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}