import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/api_service.dart';

class PortfolioProvider extends ChangeNotifier {
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  double _totalQuantity = 0;
  int _totalCost = 0;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalQuantity => _totalQuantity;
  int get totalCost => _totalCost;
  int get currentGoldPrice => 17240000;
  int get currentValue => (totalQuantity * currentGoldPrice).toInt();
  int get profit => currentValue - totalCost;
  double get profitPercentage =>
      totalCost == 0 ? 0 : (profit / totalCost) * 100;

  PortfolioProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.getTransactions();
      print('📦 Dữ liệu từ API: $data');

      _transactions = data.map((tx) {
        // 👉 SỬA LỖI: Chuyển đổi quantity từ String sang double
        double quantity;
        if (tx['quantity'] is String) {
          quantity = double.parse(tx['quantity'].toString());
        } else if (tx['quantity'] is int) {
          quantity = (tx['quantity'] as int).toDouble();
        } else if (tx['quantity'] is double) {
          quantity = tx['quantity'] as double;
        } else {
          quantity = 0.0;
        }

        return Transaction(
          date: DateTime.parse(tx['date']),
          quantity: quantity,
          price: tx['price'] is String ? int.parse(tx['price']) : tx['price'],
          type: tx['type'],
        );
      }).toList();

      // Tính tổng kết
      _totalQuantity = _transactions.fold(0.0, (sum, t) => sum + t.quantity);
      _totalCost = _transactions.fold(0, (sum, t) => sum + t.totalCost);

      print('✅ Đã tải ${_transactions.length} giao dịch');
      print('💰 Tổng số lượng: $_totalQuantity chỉ');
      print('💵 Tổng chi phí: $_totalCost đ');
    } catch (e) {
      print('❌ Lỗi loadData: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    try {
      final success = await ApiService.addTransaction(
        quantity: transaction.quantity,
        price: transaction.price,
        type: transaction.type,
        date: transaction.date,
      );

      if (success) {
        await loadData();
      } else {
        throw Exception('Thêm giao dịch thất bại');
      }
    } catch (e) {
      print('Lỗi addTransaction: $e');
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      final success = await ApiService.deleteTransaction(id);
      if (success) {
        await loadData();
      }
    } catch (e) {
      print('Lỗi deleteTransaction: $e');
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }
}
