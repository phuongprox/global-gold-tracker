import 'package:flutter/material.dart';
import '../models/gold_price.dart';
import '../services/goldapi_service.dart';

class MarketProvider extends ChangeNotifier {
  List<GoldPrice> _goldPrices = [];
  Map<String, dynamic>? _worldGoldPrice;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  List<GoldPrice> get goldPrices => _goldPrices;
  Map<String, dynamic>? get worldGoldPrice => _worldGoldPrice;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;

  List<GoldPrice> get featuredPrices {
    if (_goldPrices.length >= 3) {
      return _goldPrices.take(3).toList();
    }
    return _goldPrices;
  }

  MarketProvider() {
    fetchAllGoldData();
  }

  Future<void> fetchAllGoldData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final worldPriceVND = await GoldAPIService.getGoldPriceVND();
      _worldGoldPrice = worldPriceVND;

      final worldPrice = worldPriceVND['price_vnd'] ?? 17240000;

      _goldPrices = [
        GoldPrice(
          name: '💰 Vàng Thế Giới (XAU/USD)',
          buyPrice: (worldPriceVND['price_usd'] ?? 4595).toInt(),
          sellPrice: (worldPriceVND['price_usd'] ?? 4595).toInt(),
          isFavorite: true,
          isWorldPrice: true,
        ),
        GoldPrice(
          name: 'Vàng Thế Giới (Quy đổi VND)',
          buyPrice: worldPrice,
          sellPrice: worldPrice + 20000,
          isFavorite: true,
        ),
        GoldPrice(
          name: 'Vàng miếng SJC',
          buyPrice: worldPrice - 50000,
          sellPrice: worldPrice + 50000,
          isFavorite: true,
        ),
        GoldPrice(
          name: 'Vàng nhẫn PNJ',
          buyPrice: worldPrice - 70000,
          sellPrice: worldPrice + 30000,
          isFavorite: false,
        ),
        GoldPrice(
          name: 'Vàng nhẫn DOJI',
          buyPrice: worldPrice - 50000,
          sellPrice: worldPrice + 50000,
          isFavorite: false,
        ),
      ];

      _lastUpdated = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage =
          'Không thể kết nối đến GoldAPI. Vui lòng kiểm tra API Key.';
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshPrices() async {
    await fetchAllGoldData();
  }

  void toggleFavorite(int index) {
    if (index >= 0 && index < _goldPrices.length) {
      _goldPrices[index] = GoldPrice(
        name: _goldPrices[index].name,
        buyPrice: _goldPrices[index].buyPrice,
        sellPrice: _goldPrices[index].sellPrice,
        isFavorite: !_goldPrices[index].isFavorite,
        isWorldPrice: _goldPrices[index].isWorldPrice,
      );
      notifyListeners();
    }
  }
}
