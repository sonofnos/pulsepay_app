import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _tabs = ['/wallets', '/p2p', '/bills'];

  int _indexFor(String location) {
    if (location.startsWith('/p2p')) return 1;
    if (location.startsWith('/bills')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexFor(location),
        onDestinationSelected: (index) => context.go(_tabs[index]),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallets'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'P2P'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Bills'),
        ],
      ),
    );
  }
}
