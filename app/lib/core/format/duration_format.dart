import 'package:flutter/material.dart';

/// Formats a non-negative duration as 'H:MM:SS' (clamped at zero).
String formatHms(Duration d) {
  if (d.isNegative) d = Duration.zero;
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = d.inSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return '$h:${two(m)}:${two(s)}';
}

enum RentalUrgency { normal, warning, critical }

/// green > 60 min left; marigold within 60 min; red within 15 min or overdue.
RentalUrgency urgencyFor(Duration remaining) {
  if (remaining.inMinutes <= 15) return RentalUrgency.critical;
  if (remaining.inMinutes <= 60) return RentalUrgency.warning;
  return RentalUrgency.normal;
}

Color colorForUrgency(RentalUrgency u) {
  switch (u) {
    case RentalUrgency.normal:
      return const Color(0xFF0E9F6E); // Charge Green
    case RentalUrgency.warning:
      return const Color(0xFFF59E0B); // Marigold
    case RentalUrgency.critical:
      return const Color(0xFFDC2626); // Error red
  }
}
