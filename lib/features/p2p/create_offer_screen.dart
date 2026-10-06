import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../providers/p2p_provider.dart';
import '../../widgets/error_banner.dart';

class CreateOfferScreen extends ConsumerStatefulWidget {
  const CreateOfferScreen({super.key});

  @override
  ConsumerState<CreateOfferScreen> createState() => _CreateOfferScreenState();
}

class _CreateOfferScreenState extends ConsumerState<CreateOfferScreen> {
  String _side = 'sell';
  String _currency = 'BTC';
  final _rateController = TextEditingController();
  final _amountController = TextEditingController();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();
  String? _error;
  bool _submitting = false;

  Future<void> _submit() async {
    final rate = double.tryParse(_rateController.text);
    final amount = int.tryParse(_amountController.text);
    final min = int.tryParse(_minController.text);
    final max = int.tryParse(_maxController.text);

    if (rate == null || amount == null || min == null || max == null) {
      setState(() => _error = 'All fields must be valid numbers.');
      return;
    }

    setState(() {
      _error = null;
      _submitting = true;
    });

    try {
      await ref.read(p2pOffersProvider.notifier).createOffer(
            side: _side,
            currency: _currency,
            rate: rate,
            amount: amount,
            minOrderAmount: min,
            maxOrderAmount: max,
          );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New P2P offer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) ErrorBanner(message: _error!),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'sell', label: Text('Sell')),
                ButtonSegment(value: 'buy', label: Text('Buy')),
              ],
              selected: {_side},
              onSelectionChanged: (selection) => setState(() => _side = selection.first),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _currency,
              decoration: const InputDecoration(labelText: 'Currency', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'BTC', child: Text('BTC')),
                DropdownMenuItem(value: 'USDT', child: Text('USDT')),
              ],
              onChanged: (value) => setState(() => _currency = value!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Rate (NGN per unit)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total amount (minor units)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min order', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Max order', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Publish offer'),
            ),
          ],
        ),
      ),
    );
  }
}
