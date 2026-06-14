import 'dart:math';

/// Generates a unique idempotency key for one checkout attempt.
String newIdempotencyKey() {
  final ts = DateTime.now().microsecondsSinceEpoch;
  final rand = Random().nextInt(1 << 32);
  return '$ts-$rand';
}
