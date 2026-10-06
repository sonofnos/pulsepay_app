class P2pTrade {
  final int id;
  final int offerId;
  final int makerId;
  final int takerId;
  final int amount;
  final double fiatAmount;
  final String status;
  final String? offerCurrency;
  final String? offerSide;

  P2pTrade({
    required this.id,
    required this.offerId,
    required this.makerId,
    required this.takerId,
    required this.amount,
    required this.fiatAmount,
    required this.status,
    this.offerCurrency,
    this.offerSide,
  });

  factory P2pTrade.fromJson(Map<String, dynamic> json) {
    final offer = json['offer'] as Map<String, dynamic>?;

    return P2pTrade(
      id: json['id'] as int,
      offerId: json['offer_id'] as int,
      makerId: json['maker_id'] as int,
      takerId: json['taker_id'] as int,
      amount: json['amount'] as int,
      fiatAmount: double.parse(json['fiat_amount'].toString()),
      status: json['status'] as String,
      offerCurrency: offer?['currency'] as String?,
      offerSide: offer?['side'] as String?,
    );
  }
}
