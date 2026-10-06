import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ledger_entry.dart';
import '../models/wallet.dart';
import 'api_provider.dart';

class WalletsNotifier extends AsyncNotifier<List<Wallet>> {
  @override
  Future<List<Wallet>> build() => _fetch();

  Future<List<Wallet>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/wallets');
    final list = (response['data'] as List).cast<Map<String, dynamic>>();
    return list.map(Wallet.fromJson).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> transfer({
    required String recipientEmail,
    required String currency,
    required int amountMinorUnits,
  }) async {
    final api = ref.read(apiClientProvider);
    await api.post(
      '/wallets/transfer',
      idempotent: true,
      body: {
        'recipient_email': recipientEmail,
        'currency': currency,
        'amount': amountMinorUnits,
      },
    );
    await refresh();
  }
}

final walletsProvider = AsyncNotifierProvider<WalletsNotifier, List<Wallet>>(WalletsNotifier.new);

final walletTransactionsProvider =
    FutureProvider.family<List<LedgerEntry>, int>((ref, walletId) async {
  final api = ref.read(apiClientProvider);
  final response = await api.get('/wallets/$walletId/transactions');
  final list = (response['data'] as List).cast<Map<String, dynamic>>();
  return list.map(LedgerEntry.fromJson).toList();
});
