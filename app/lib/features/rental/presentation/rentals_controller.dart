import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/rental.dart';

class RentalsController extends AsyncNotifier<List<Rental>> {
  @override
  Future<List<Rental>> build() =>
      ref.read(rentalsRepositoryProvider).list(status: RentalStatus.active);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(rentalsRepositoryProvider).list(status: RentalStatus.active));
  }
}

final rentalsControllerProvider =
    AsyncNotifierProvider<RentalsController, List<Rental>>(RentalsController.new);
