class Wallet {
  final int id;
  final String currency;
  final int balance;

  Wallet({required this.id, required this.currency, required this.balance});

  factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'] as int,
        currency: json['currency'] as String,
        balance: json['balance'] as int,
      );
}
