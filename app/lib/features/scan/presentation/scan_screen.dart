import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/deeplink/cabinet_link.dart';
import 'cabinet_code_field.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _handled = false;

  void _open(BuildContext context, String deviceId) {
    if (_handled) return;
    _handled = true;
    context.go('/c/$deviceId');
  }

  void _onDetect(BarcodeCapture capture) {
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      final id = parseCabinetId(raw);
      if (id != null) {
        _open(context, id);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skani QR / Scan QR')),
      body: Column(
        children: [
          Expanded(child: MobileScanner(onDetect: _onDetect)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Au weka namba / Or enter code'),
                const SizedBox(height: 8),
                CabinetCodeField(onSubmit: (id) => _open(context, id)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
