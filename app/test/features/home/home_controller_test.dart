import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marijoy_app/features/home/presentation/home_controller.dart';

void main() {
  test('loads cabinets from the mock repository', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final cabinets = await c.read(homeControllerProvider.future);
    expect(cabinets, isNotEmpty);
    expect(cabinets.first.id, isNotEmpty);
  });
}
