import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../core/money.dart';
import '../../providers/wallets_provider.dart';
import '../../widgets/error_banner.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  String _currency = 'NGN';
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
      await ref.read(walletsProvider.notifier).transfer(
            recipientEmail: _emailController.text.trim(),
            currency: _currency,
            amountMinorUnits: amount,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transfer sent.')));
        Navigator.of(context).pop();
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send money')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Recipient email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'NGN', child: Text('NGN')),
                DropdownMenuItem(value: 'BTC', child: Text('BTC')),
                DropdownMenuItem(value: 'USDT', child: Text('USDT')),
              ],
              onChanged: (value) => setState(() => _currency = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
