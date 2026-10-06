import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_exception.dart';
import '../../models/p2p_trade.dart';
import '../../providers/auth_provider.dart';
import '../../providers/p2p_provider.dart';

// Deep-link target: pulsepay://app/p2p/trades/{id}
class TradeDetailScreen extends ConsumerWidget {
  final int tradeId;

  const TradeDetailScreen({super.key, required this.tradeId});

  bool _isSeller(P2pTrade trade, int userId) {
    return trade.offerSide == 'sell' ? trade.makerId == userId : trade.takerId == userId;
  }

  bool _isBuyer(P2pTrade trade, int userId) {
    return trade.offerSide == 'sell' ? trade.takerId == userId : trade.makerId == userId;
  }

  Future<void> _act(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(p2pTradesProvider);
    final authState = ref.watch(authProvider);
    final userId = authState is AuthAuthenticated ? authState.user.id : null;

    return Scaffold(
      appBar: AppBar(title: Text('Trade #$tradeId')),
      body: tradesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        data: (trades) {
          final trade = trades.where((t) => t.id == tradeId).firstOrNull;
          if (trade == null || userId == null) {
            return const Center(child: Text('Trade not found.'));
          }

          final isSeller = _isSeller(trade, userId);
          final isBuyer = _isBuyer(trade, userId);
          final notifier = ref.read(p2pTradesProvider.notifier);

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: ${trade.status.replaceAll('_', ' ')}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Amount: ${trade.amount} ${trade.offerCurrency ?? ''}'),
                Text('Fiat amount: NGN ${trade.fiatAmount.toStringAsFixed(2)}'),
                Text(isSeller ? 'Your role: Seller' : (isBuyer ? 'Your role: Buyer' : '')),
                const SizedBox(height: 32),
                if (trade.status == 'pending_payment' && isBuyer)
                  FilledButton(
                    onPressed: () => _act(context, ref, () => notifier.confirmPayment(trade.id)),
                    child: const Text("I've sent the fiat payment"),
                  ),
                if (trade.status == 'paid_confirmed' && isSeller)
                  FilledButton(
                    onPressed: () => _act(context, ref, () => notifier.release(trade.id)),
                    child: const Text('Release escrow to buyer'),
                  ),
                if (trade.status == 'pending_payment')
                  TextButton(
                    onPressed: () => _act(context, ref, () => notifier.cancel(trade.id)),
                    child: const Text('Cancel trade'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
