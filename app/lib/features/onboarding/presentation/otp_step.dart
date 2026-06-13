import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_mapper.dart';
import '../../../mock/mock_auth_repository.dart';
import 'auth_controller.dart';

class OtpStep extends ConsumerStatefulWidget {
  const OtpStep({super.key, required this.phone});
  final String phone;
  @override
  ConsumerState<OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends ConsumerState<OtpStep> {
  final _controller = TextEditingController();
  String? _error;
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final localeCode = Localizations.localeOf(context).languageCode;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).verifyOtp(_controller.text.trim());
    } on AuthException {
      setState(() => _error = 'Msimbo si sahihi / Wrong code');
    } on AppException catch (ex) {
      setState(() => _error = ErrorMapper.message(ex, localeCode));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weka msimbo / Enter code')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Tumetuma msimbo kwa ${widget.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(labelText: 'OTP', errorText: _error),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _verify,
              child: _busy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Thibitisha / Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
