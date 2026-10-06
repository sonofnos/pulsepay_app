import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/p2p_provider.dart';

class TradesScreen extends ConsumerWidget {
  const TradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradesAsync = ref.watch(p2pTradesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My trades')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(p2pTradesProvider.notifier).refresh(),
        child: tradesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load: $err')),
          data: (trades) {
            if (trades.isEmpty) {
              return ListView(children: const [
                Padding(padding: EdgeInsets.all(32), child: Center(child: Text('No trades yet.'))),
              ]);
            }
            return ListView.builder(
              itemCount: trades.length,
              itemBuilder: (context, index) {
                final trade = trades[index];
                return ListTile(
                  title: Text('${trade.offerCurrency ?? ''} trade #${trade.id}'),
                  subtitle: Text(trade.status.replaceAll('_', ' ')),
                  trailing: Text(trade.amount.toString()),
                  onTap: () => context.push('/p2p/trades/${trade.id}'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
