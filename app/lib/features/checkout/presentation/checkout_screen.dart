import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/format/money.dart';
import '../../../core/payments/wallet_detect.dart';
import '../../../core/providers.dart';
import '../../../core/util/idempotency.dart';
import '../../../domain/models/cabinet.dart';
import '../../../domain/models/wallet.dart';
import '../../onboarding/presentation/auth_controller.dart';
import 'checkout_providers.dart';

const kPerUserMaxBanks = 3;

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key, required this.cabinetId});
  final String cabinetId;
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _qty = 1;
  Wallet? _wallet;
  bool _walletInitialized = false;
  bool _submitting = false;

  String? get _userPhone => ref
      .read(authControllerProvider)
      .maybeWhen(authenticated: (u) => u.phone, orElse: () => null);

  Future<void> _pay(Cabinet cabinet) async {
    setState(() => _submitting = true);
    try {
      final order = await ref.read(ordersRepositoryProvider).create(
            cabinetId: cabinet.id,
            qty: _qty,
            wallet: _wallet,
            idempotencyKey: newIdempotencyKey(),
          );
      if (mounted) context.go('/orders/${order.id}');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(cabinetDetailProvider(widget.cabinetId));
    return Scaffold(
      appBar: AppBar(title: const Text('Kodisha / Rent')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('Imeshindikana kupata cabinet.')),
        data: (cabinet) {
          if (!cabinet.online) {
            return const Center(child: Text('Cabinet hii haipo mtandaoni / offline'));
          }
          final maxQty = cabinet.banksAvailable < kPerUserMaxBanks
              ? cabinet.banksAvailable
              : kPerUserMaxBanks;
          if (maxQty < 1) {
            return const Center(child: Text('Hakuna benki / No banks available'));
          }
          if (_qty > maxQty) _qty = maxQty;
          if (!_walletInitialized) {
            final phone = _userPhone;
            _wallet = phone == null ? null : detectWallet(phone);
            _walletInitialized = true;
          }
          final unit = cabinet.unitPriceTzs ?? 0;
          final total = unit * _qty;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(cabinet.label, style: Theme.of(context).textTheme.titleLarge),
                Text('Benki ${cabinet.banksAvailable} • Nafasi ${cabinet.freeSlots}'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Idadi / Quantity'),
                    Row(children: [
                      IconButton(
                        key: const Key('qtyMinus'),
                        onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$_qty', style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        key: const Key('qtyPlus'),
                        onPressed: _qty < maxQty ? () => setState(() => _qty++) : null,
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Wallet>(
                  key: const Key('walletDropdown'),
                  initialValue: _wallet,
                  decoration: const InputDecoration(labelText: 'Mtandao wa pesa / Wallet'),
                  items: Wallet.values
                      .map((w) => DropdownMenuItem(value: w, child: Text(w.name.toUpperCase())))
                      .toList(),
                  onChanged: (w) => setState(() => _wallet = w),
                ),
                const Spacer(),
                Text('Jumla / Total: ${formatTzs(total)}',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: (_submitting || _wallet == null) ? null : () => _pay(cabinet),
                  child: _submitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text('Lipa / Pay ${formatTzs(total)}'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
