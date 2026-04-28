import 'package:flutter/material.dart';
import '../models/transaction.dart';

class PortfolioProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  // Thống kê
  double get totalQuantity =>
      _transactions.fold(0.0, (sum, t) => sum + t.quantity);
  int get totalCost => _transactions.fold(0, (sum, t) => sum + t.totalCost);

  // Giả sử giá vàng hiện tại là 17,240,000 đ/chỉ
  int get currentGoldPrice => 17240000;
  int get currentValue => (totalQuantity * currentGoldPrice).toInt();
  int get profit => currentValue - totalCost;
  double get profitPercentage =>
      totalCost == 0 ? 0 : (profit / totalCost) * 100;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
  }

  void removeTransaction(int index) {
    _transactions.removeAt(index);
    notifyListeners();
  }
}
