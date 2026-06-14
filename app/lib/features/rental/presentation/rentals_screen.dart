import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'rental_timer_card.dart';
import 'rentals_controller.dart';

class RentalsScreen extends ConsumerWidget {
  const RentalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(rentalsControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kukodi kwangu / My rentals'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Hitilafu / Error')),
        data: (rentals) => rentals.isEmpty
            ? const Center(child: Text('Huna kukodi kwa sasa / No active rentals'))
            : ListView(
                children: [
                  for (final r in rentals)
                    RentalTimerCard(
                      rental: r,
                      onReportBad: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Imepokelewa / Reported')),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
