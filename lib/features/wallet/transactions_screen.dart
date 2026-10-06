import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/money.dart';
import '../../providers/wallets_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  final int walletId;
  final String currency;

  const TransactionsScreen({super.key, required this.walletId, required this.currency});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(walletTransactionsProvider(walletId));

    return Scaffold(
      appBar: AppBar(title: Text('$currency transactions')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load: $err')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No transactions yet.'));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final isCredit = entry.direction == 'credit';
              return ListTile(
                leading: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
                title: Text(entry.type.replaceAll('_', ' ')),
                subtitle: Text(DateFormat.yMMMd().add_jm().format(entry.createdAt.toLocal())),
                trailing: Text(
                  '${isCredit ? '+' : '-'}${Money.format(entry.amount, currency)}',
                  style: TextStyle(color: isCredit ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
