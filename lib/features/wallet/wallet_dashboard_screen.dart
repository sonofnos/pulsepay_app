import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/money.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallets_provider.dart';

class WalletDashboardScreen extends ConsumerWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletsProvider);
    final authState = ref.watch(authProvider);
    final name = authState is AuthAuthenticated ? authState.user.name : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, $name'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/transfer'),
        icon: const Icon(Icons.send),
        label: const Text('Transfer'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(walletsProvider.notifier).refresh(),
        child: walletsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => ListView(children: [Center(child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Failed to load wallets: $err'),
          ))]),
          data: (wallets) => ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: wallets.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(child: Text(wallet.currency.substring(0, 1))),
                  title: Text(wallet.currency),
                  subtitle: const Text('Tap to view transactions'),
                  trailing: Text(
                    Money.format(wallet.balance, wallet.currency),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  onTap: () => context.push('/wallets/${wallet.id}/transactions?currency=${wallet.currency}'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
