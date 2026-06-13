import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/phone/tz_phone.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import 'auth_controller.dart';

class PhoneStep extends ConsumerStatefulWidget {
  const PhoneStep({super.key});
  @override
  ConsumerState<PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends ConsumerState<PhoneStep> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final e164 = TzPhone.normalize(_controller.text);
    if (e164 == null) {
      setState(() => _error = 'Namba si sahihi / Invalid number');
      return;
    }
    final localeCode = Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).requestOtp(e164);
    } on AppException catch (ex) {
      setState(() => _error = ErrorMapper.message(ex, localeCode));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingiza namba / Enter number')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                prefixText: '+255 ',
                labelText: 'Namba ya simu',
                errorText: _error,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Endelea / Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
