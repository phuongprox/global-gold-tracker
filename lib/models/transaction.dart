class Transaction {
  final DateTime date;
  final double quantity;
  final int price;
  final String type;

  Transaction({
    required this.date,
    required this.quantity,
    required this.price,
    required this.type,
  });

  int get totalCost => (quantity * price).toInt();
}
