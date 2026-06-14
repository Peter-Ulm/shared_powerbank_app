import 'package:flutter/material.dart';
import '../../../core/theme/marijoy_colors.dart';
import '../../../domain/models/cabinet.dart';

class CabinetCard extends StatelessWidget {
  const CabinetCard({super.key, required this.cabinet, this.onTap});
  final Cabinet cabinet;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final distance = cabinet.distanceMeters;
    final distanceText = distance == null
        ? ''
        : distance < 1000
            ? '${distance.round()} m'
            : '${(distance / 1000).toStringAsFixed(1)} km';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: cabinet.online ? onTap : null,
        leading: CircleAvatar(
          backgroundColor: cabinet.online ? MariJoyColors.chargeGreen : MariJoyColors.slate,
          child: Icon(cabinet.online ? Icons.bolt : Icons.bolt_outlined, color: Colors.white),
        ),
        title: Text(cabinet.label),
        subtitle: Row(
          children: [
            const Icon(Icons.battery_charging_full, size: 16, color: MariJoyColors.chargeGreen),
            const SizedBox(width: 4),
            Text('${cabinet.banksAvailable}'),
            const SizedBox(width: 12),
            const Icon(Icons.local_parking, size: 16, color: MariJoyColors.info),
            const SizedBox(width: 4),
            Text('${cabinet.freeSlots}'),
            const Spacer(),
            if (distanceText.isNotEmpty) Text(distanceText),
          ],
        ),
        trailing: cabinet.online
            ? const Icon(Icons.chevron_right)
            : const Text('Nje ya mtandao', style: TextStyle(color: MariJoyColors.error, fontSize: 12)),
      ),
    );
  }
}
