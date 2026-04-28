class Transaction {
  final DateTime date;
  final double quantity;
  final int price;
  final String type; // 'BUY' or 'SELL'

  Transaction({
    required this.date,
    required this.quantity,
    required this.price,
    required this.type,
  });

  int get totalCost => (quantity * price).toInt();

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'quantity': quantity,
      'price': price,
      'type': type,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      date: DateTime.parse(map['date']),
      quantity: map['quantity'],
      price: map['price'],
      type: map['type'],
    );
  }
}
