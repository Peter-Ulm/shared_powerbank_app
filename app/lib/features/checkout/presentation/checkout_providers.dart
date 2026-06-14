import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/cabinet.dart';

/// Loads a cabinet's live detail/availability for checkout.
final cabinetDetailProvider = FutureProvider.family<Cabinet, String>((ref, id) {
  return ref.read(cabinetsRepositoryProvider).byId(id);
});
