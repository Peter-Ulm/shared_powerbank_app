import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/format/duration_format.dart';
import '../../../domain/models/rental.dart';

/// Renders a per-bank 5-hour countdown from server timestamps. The `now`
/// parameter is injectable for tests; production uses the wall clock.
class RentalTimerCard extends StatefulWidget {
  const RentalTimerCard({super.key, required this.rental, this.onReportBad, this.now});
  final Rental rental;
  final VoidCallback? onReportBad;
  final DateTime Function()? now;

  @override
  State<RentalTimerCard> createState() => _RentalTimerCardState();
}

class _RentalTimerCardState extends State<RentalTimerCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    if (widget.now == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = (widget.now ?? DateTime.now)();
    final remaining = widget.rental.dueAt.difference(now);
    final overdue = remaining.isNegative;
    final urgency = urgencyFor(remaining);
    final color = colorForUrgency(urgency);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Benki ${widget.rental.powerbankId}',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              overdue ? 'Imechelewa / Overdue' : formatHms(remaining),
              style: Theme.of(context)
                  .textTheme
                  .displaySmall
                  ?.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            const SizedBox(height: 8),
            if (widget.onReportBad != null)
              TextButton.icon(
                onPressed: widget.onReportBad,
                icon: const Icon(Icons.report_problem_outlined, size: 18),
                label: const Text('Ripoti benki mbovu'),
              ),
          ],
        ),
      ),
    );
  }
}
