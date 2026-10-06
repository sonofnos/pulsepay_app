class LedgerEntry {
  final int id;
  final String direction;
  final int amount;
  final int balanceAfter;
  final String type;
  final DateTime createdAt;

  LedgerEntry({
    required this.id,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    required this.type,
    required this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) => LedgerEntry(
        id: json['id'] as int,
        direction: json['direction'] as String,
        amount: json['amount'] as int,
        balanceAfter: json['balance_after'] as int,
        type: json['type'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}
