class Transaction {
  final DateTime date;
  final double quantity; // lượng vàng (chỉ)
  final int price; // giá mua vào thời điểm đó
  final String type; // 'BUY' or 'SELL'

  Transaction({
    required this.date,
    required this.quantity,
    required this.price,
    required this.type,
  });

  int get totalCost => (quantity * price).toInt();
}
