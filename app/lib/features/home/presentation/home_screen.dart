import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/models/cabinet.dart';
import 'cabinet_card.dart';
import 'home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cabinetsAsync = ref.watch(homeControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cabinets karibu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(homeControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/scan'),
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Skani / Scan'),
      ),
      body: cabinetsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Imeshindikana kupakia. Jaribu tena.')),
        data: (cabinets) => Column(
          children: [
            SizedBox(height: 200, child: _CabinetMap(cabinets: cabinets)),
            Expanded(
              child: cabinets.isEmpty
                  ? const Center(child: Text('Hakuna cabinets karibu.'))
                  : ListView.builder(
                      itemCount: cabinets.length,
                      itemBuilder: (_, i) => CabinetCard(
                        cabinet: cabinets[i],
                        onTap: () => context.push('/c/${cabinets[i].id}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CabinetMap extends StatelessWidget {
  const _CabinetMap({required this.cabinets});
  final List<Cabinet> cabinets;

  @override
  Widget build(BuildContext context) {
    final center = cabinets.isNotEmpty
        ? LatLng(cabinets.first.lat, cabinets.first.lng)
        : const LatLng(-6.776, 39.178);
    return FlutterMap(
      options: MapOptions(initialCenter: center, initialZoom: 12),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'tz.marijoy.marijoy_app',
        ),
        MarkerLayer(
          markers: [
            for (final c in cabinets)
              Marker(
                point: LatLng(c.lat, c.lng),
                child: Icon(Icons.location_on,
                    color: c.online ? Colors.green : Colors.grey, size: 32),
              ),
          ],
        ),
      ],
    );
  }
}
