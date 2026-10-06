import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/bill_payment.dart';
import 'api_provider.dart';

class BillPaymentsNotifier extends AsyncNotifier<List<BillPayment>> {
  @override
  Future<List<BillPayment>> build() => _fetch();

  Future<List<BillPayment>> _fetch() async {
    final api = ref.read(apiClientProvider);
    final response = await api.get('/bill-payments');
    final list = (response['data'] as List).cast<Map<String, dynamic>>();
    return list.map(BillPayment.fromJson).toList();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<BillPayment> pay({required String type, required String recipient, required int amount}) async {
    final api = ref.read(apiClientProvider);
    final response = await api.post(
      '/bill-payments',
      idempotent: true,
      body: {'type': type, 'recipient': recipient, 'amount': amount},
    );
    await refresh();
    return BillPayment.fromJson(response);
  }
}

final billPaymentsProvider =
    AsyncNotifierProvider<BillPaymentsNotifier, List<BillPayment>>(BillPaymentsNotifier.new);
