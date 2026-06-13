import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'language_step.dart';
import 'phone_step.dart';
import 'otp_step.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});
  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  bool _languageChosen = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final otpPhone = auth.maybeWhen(otpSent: (p) => p, orElse: () => null);
    if (otpPhone != null) return OtpStep(phone: otpPhone);
    if (!_languageChosen) {
      return LanguageStep(onChosen: () => setState(() => _languageChosen = true));
    }
    return const PhoneStep();
  }
}
