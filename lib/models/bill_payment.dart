class BillPayment {
  final int id;
  final String type;
  final String recipient;
  final int amount;
  final String status;
  final String? providerReference;

  BillPayment({
    required this.id,
    required this.type,
    required this.recipient,
    required this.amount,
    required this.status,
    this.providerReference,
  });

  factory BillPayment.fromJson(Map<String, dynamic> json) => BillPayment(
        id: json['id'] as int,
        type: json['type'] as String,
        recipient: json['recipient'] as String,
        amount: json['amount'] as int,
        status: json['status'] as String,
        providerReference: json['provider_reference'] as String?,
      );
}
