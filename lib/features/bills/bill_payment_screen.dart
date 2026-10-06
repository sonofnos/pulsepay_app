import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/money.dart';
import '../../core/notifications.dart';
import '../../providers/bills_provider.dart';
import '../../widgets/error_banner.dart';

class BillPaymentScreen extends ConsumerStatefulWidget {
  const BillPaymentScreen({super.key});

  @override
  ConsumerState<BillPaymentScreen> createState() => _BillPaymentScreenState();
}

class _BillPaymentScreenState extends ConsumerState<BillPaymentScreen> {
  String _type = 'airtime';
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  String? _error;
  bool _submitting = false;

  Future<void> _submit() async {
    final amount = Money.parseToMinorUnits(_amountController.text);
    if (amount == null) {
      setState(() => _error = 'Enter a valid amount.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      final payment = await ref.read(billPaymentsProvider.notifier).pay(
            type: _type,
            recipient: _recipientController.text.trim(),
            amount: amount,
          );
      await AppNotifications.show(
        title: 'Bill payment ${payment.status}',
        body: '${payment.type} to ${payment.recipient}: ${Money.format(payment.amount, 'NGN')}',
      );
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment successful.')));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
      await AppNotifications.show(title: 'Bill payment failed', body: e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(billPaymentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pay bills')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'airtime', child: Text('Airtime')),
                DropdownMenuItem(value: 'data', child: Text('Data')),
                DropdownMenuItem(value: 'electricity', child: Text('Electricity')),
              ],
              onChanged: (value) => setState(() => _type = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _recipientController,
              decoration: const InputDecoration(
                labelText: 'Phone / meter number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount (NGN)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Pay'),
            ),
            const SizedBox(height: 32),
            Text('History', style: Theme.of(context).textTheme.titleMedium),
            history.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Failed to load: $err'),
              data: (payments) => Column(
                children: payments
                    .map((p) => ListTile(
                          title: Text('${p.type} • ${p.recipient}'),
                          subtitle: Text(p.status),
                          trailing: Text(Money.format(p.amount, 'NGN')),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
