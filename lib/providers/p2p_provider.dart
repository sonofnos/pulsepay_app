import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/notifications.dart';
import '../models/p2p_offer.dart';
import '../models/p2p_trade.dart';
import 'api_provider.dart';

class P2pOffersNotifier extends AsyncNotifier<List<P2pOffer>> {
  @override
  Future<List<P2pOffer>> build() => _fetch();

  Future<List<P2pOffer>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/p2p/offers');
    final list = (response['data'] as List).cast<Map<String, dynamic>>();
    return list.map(P2pOffer.fromJson).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createOffer({
    required String side,
    required String currency,
    required double rate,
    required int amount,
    required int minOrderAmount,
    required int maxOrderAmount,
  }) async {
    final api = ref.read(apiClientProvider);
    await api.post('/p2p/offers', body: {
      'side': side,
      'currency': currency,
      'rate': rate,
      'amount': amount,
      'min_order_amount': minOrderAmount,
      'max_order_amount': maxOrderAmount,
    });
    await refresh();
  }
}

final p2pOffersProvider = AsyncNotifierProvider<P2pOffersNotifier, List<P2pOffer>>(P2pOffersNotifier.new);

class P2pTradesNotifier extends AsyncNotifier<List<P2pTrade>> {
  @override
  Future<List<P2pTrade>> build() => _fetch();

  Future<List<P2pTrade>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/p2p/trades');
    final list = (response['data'] as List).cast<Map<String, dynamic>>();
    return list.map(P2pTrade.fromJson).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> initiateTrade(int offerId, int amount) async {
    final api = ref.read(apiClientProvider);
    await api.post('/p2p/offers/$offerId/trades', idempotent: true, body: {'amount': amount});
    await refresh();
  }

  Future<void> confirmPayment(int tradeId) async {
    final api = ref.read(apiClientProvider);
    await api.post('/p2p/trades/$tradeId/confirm-payment');
    await refresh();
    await AppNotifications.show(
      title: 'Payment confirmed',
      body: 'Trade #$tradeId: fiat payment confirmed, awaiting seller release.',
    );
  }

  Future<void> release(int tradeId) async {
    final api = ref.read(apiClientProvider);
    await api.post('/p2p/trades/$tradeId/release', idempotent: true);
    await refresh();
    await AppNotifications.show(
      title: 'Trade completed',
      body: 'Trade #$tradeId: escrow released to the buyer.',
    );
  }

  Future<void> cancel(int tradeId) async {
    final api = ref.read(apiClientProvider);
    await api.post('/p2p/trades/$tradeId/cancel');
    await refresh();
  }
}

final p2pTradesProvider = AsyncNotifierProvider<P2pTradesNotifier, List<P2pTrade>>(P2pTradesNotifier.new);
