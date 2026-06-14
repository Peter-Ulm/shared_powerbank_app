import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../domain/models/cabinet.dart';

class HomeController extends AsyncNotifier<List<Cabinet>> {
  Future<List<Cabinet>> _load() async {
    final loc = await ref.read(locationServiceProvider).current();
    return ref.read(cabinetsRepositoryProvider).nearby(lat: loc.lat, lng: loc.lng);
  }

  @override
  Future<List<Cabinet>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }
}

final homeControllerProvider =
    AsyncNotifierProvider<HomeController, List<Cabinet>>(HomeController.new);
