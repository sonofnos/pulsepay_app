import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/bills/bill_payment_screen.dart';
import 'features/p2p/create_offer_screen.dart';
import 'features/p2p/offers_screen.dart';
import 'features/p2p/trade_detail_screen.dart';
import 'features/p2p/trades_screen.dart';
import 'features/wallet/transactions_screen.dart';
import 'features/wallet/transfer_screen.dart';
import 'features/wallet/wallet_dashboard_screen.dart';
import 'providers/auth_provider.dart';
import 'widgets/app_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/wallets',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (authState is AuthLoading) return null;
      if (authState is AuthUnauthenticated && !loggingIn) return '/login';
      if (authState is AuthAuthenticated && loggingIn) return '/wallets';
      return null;
    },
    refreshListenable: _AuthRefreshListenable(ref),
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/wallets', builder: (context, state) => const WalletDashboardScreen()),
          GoRoute(
            path: '/wallets/:id/transactions',
            builder: (context, state) => TransactionsScreen(
              walletId: int.parse(state.pathParameters['id']!),
              currency: state.uri.queryParameters['currency'] ?? '',
            ),
          ),
          GoRoute(path: '/transfer', builder: (context, state) => const TransferScreen()),
          GoRoute(path: '/p2p', builder: (context, state) => const OffersScreen()),
          GoRoute(path: '/p2p/offers/new', builder: (context, state) => const CreateOfferScreen()),
          GoRoute(path: '/p2p/trades', builder: (context, state) => const TradesScreen()),
          GoRoute(
            path: '/p2p/trades/:id',
            builder: (context, state) => TradeDetailScreen(tradeId: int.parse(state.pathParameters['id']!)),
          ),
          GoRoute(path: '/bills', builder: (context, state) => const BillPaymentScreen()),
        ],
      ),
    ],
  );
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(Ref ref) {
    ref.listen(authProvider, (previous, next) => notifyListeners());
  }
}
