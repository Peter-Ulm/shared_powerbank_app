import 'package:flutter/material.dart';
import '../../../core/deeplink/cabinet_link.dart';

class CabinetCodeField extends StatefulWidget {
  const CabinetCodeField({super.key, required this.onSubmit});
  final void Function(String deviceId) onSubmit;

  @override
  State<CabinetCodeField> createState() => _CabinetCodeFieldState();
}

class _CabinetCodeFieldState extends State<CabinetCodeField> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final id = parseCabinetId(_controller.text);
    if (id == null) {
      setState(() => _error = 'Namba ya cabinet si sahihi / Invalid cabinet code');
      return;
    }
    setState(() => _error = null);
    widget.onSubmit(id);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: 'Namba ya cabinet', errorText: _error),
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(onPressed: _submit, child: const Text('Fungua / Open')),
      ],
    );
  }
}
