class P2pOffer {
  final int id;
  final int makerId;
  final String? makerName;
  final String side;
  final String currency;
  final String fiatCurrency;
  final double rate;
  final int amount;
  final int remainingAmount;
  final int minOrderAmount;
  final int maxOrderAmount;
  final String status;

  P2pOffer({
    required this.id,
    required this.makerId,
    this.makerName,
    required this.side,
    required this.currency,
    required this.fiatCurrency,
    required this.rate,
    required this.amount,
    required this.remainingAmount,
    required this.minOrderAmount,
    required this.maxOrderAmount,
    required this.status,
  });

  factory P2pOffer.fromJson(Map<String, dynamic> json) => P2pOffer(
        id: json['id'] as int,
        makerId: json['maker_id'] as int,
        makerName: (json['maker'] as Map<String, dynamic>?)?['name'] as String?,
        side: json['side'] as String,
        currency: json['currency'] as String,
        fiatCurrency: json['fiat_currency'] as String,
        rate: double.parse(json['rate'].toString()),
        amount: json['amount'] as int,
        remainingAmount: json['remaining_amount'] as int,
        minOrderAmount: json['min_order_amount'] as int,
        maxOrderAmount: json['max_order_amount'] as int,
        status: json['status'] as String,
      );
}
