import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api_exception.dart';
import '../../models/p2p_offer.dart';
import '../../providers/p2p_provider.dart';

class OffersScreen extends ConsumerWidget {
  const OffersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(p2pOffersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('P2P market'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'My trades',
            onPressed: () => context.push('/p2p/trades'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/p2p/offers/new'),
        icon: const Icon(Icons.add),
        label: const Text('New offer'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(p2pOffersProvider.notifier).refresh(),
        child: offersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load offers: $err')),
          data: (offers) {
            if (offers.isEmpty) {
              return ListView(children: const [
                Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No open offers right now.'))),
              ]);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              itemBuilder: (context, index) => _OfferCard(offer: offers[index]),
            );
          },
        ),
      ),
    );
  }
}

class _OfferCard extends ConsumerWidget {
  final P2pOffer offer;

  const _OfferCard({required this.offer});

  Future<void> _trade(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final amount = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${offer.side == 'sell' ? 'Buy' : 'Sell'} ${offer.currency}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Amount (minor units, ${offer.minOrderAmount}-${offer.maxOrderAmount})',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(controller.text)),
            child: const Text('Trade'),
          ),
        ],
      ),
    );

    if (amount == null) return;

    try {
      await ref.read(p2pTradesProvider.notifier).initiateTrade(offer.id, amount);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Trade opened, funds escrowed.')));
        context.push('/p2p/trades');
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('${offer.side == 'sell' ? 'Sell' : 'Buy'} ${offer.currency} • ${offer.makerName ?? 'Trader'}'),
        subtitle: Text(
          'Rate: ${offer.fiatCurrency} ${offer.rate.toStringAsFixed(2)} per unit\n'
          'Available: ${offer.remainingAmount} (min ${offer.minOrderAmount} / max ${offer.maxOrderAmount})',
        ),
        isThreeLine: true,
        trailing: FilledButton(onPressed: () => _trade(context, ref), child: const Text('Trade')),
      ),
    );
  }
}
