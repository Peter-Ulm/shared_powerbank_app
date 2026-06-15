import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/rental.dart';

/// All rentals (active + past), newest first.
final historyProvider = FutureProvider<List<Rental>>((ref) async {
  final list = await ref.read(rentalsRepositoryProvider).list();
  final sorted = [...list]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  return sorted;
});
