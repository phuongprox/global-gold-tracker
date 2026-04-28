import 'package:flutter/material.dart';
import '../models/gold_price.dart';
import '../services/goldapi_service.dart';

class MarketProvider extends ChangeNotifier {
  final GoldAPIService _goldAPIService = GoldAPIService();

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

  // Lấy 3 giá vàng nổi bật cho trang chủ
  List<GoldPrice> get featuredPrices {
    if (_goldPrices.length >= 3) {
      return _goldPrices.take(3).toList();
    }
    return _goldPrices;
  }

  MarketProvider() {
    fetchAllGoldData();
  }

  /// Lấy tất cả dữ liệu vàng
  Future<void> fetchAllGoldData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Lấy giá vàng thế giới quy đổi sang VND
      final worldPriceVND = await _goldAPIService.getGoldPriceVND();
      _worldGoldPrice = worldPriceVND;

      // Tạo danh sách giá vàng trong nước (tham khảo từ giá thế giới)
      final worldPrice = worldPriceVND['price_vnd'] ?? 17240000;

      _goldPrices = [
        GoldPrice(
          name: '💰 Vàng Thế Giới (XAU/USD)',
          buyPrice: (worldPriceVND['price_usd'] ?? 2350).toInt(),
          sellPrice: (worldPriceVND['price_usd'] ?? 2350).toInt(),
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
        GoldPrice(
          name: 'Vàng nhẫn Bảo Tín Minh Châu',
          buyPrice: worldPrice - 60000,
          sellPrice: worldPrice + 40000,
          isFavorite: false,
        ),
        GoldPrice(
          name: 'Vàng nhẫn Phú Quý',
          buyPrice: worldPrice - 80000,
          sellPrice: worldPrice + 20000,
          isFavorite: false,
        ),
      ];

      _lastUpdated = DateTime.now();
      _errorMessage = null;
    } catch (e) {
      _errorMessage =
          'Không thể kết nối đến GoldAPI. Vui lòng kiểm tra kết nối mạng.';
      print('Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh dữ liệu
  Future<void> refreshPrices() async {
    await fetchAllGoldData();
  }

  /// Chỉ refresh giá thế giới
  Future<void> refreshWorldPrice() async {
    try {
      final worldPrice = await _goldAPIService.getGoldPriceVND();
      _worldGoldPrice = worldPrice;
      notifyListeners();
    } catch (e) {
      print('Error refreshing world price: $e');
    }
  }

  /// Toggle favorite
  void toggleFavorite(int index) {
    if (index >= 0 && index < _goldPrices.length) {
      _goldPrices[index] = GoldPrice(
        name: _goldPrices[index].name,
        buyPrice: _goldPrices[index].buyPrice,
        sellPrice: _goldPrices[index].sellPrice,
        isFavorite: !_goldPrices[index].isFavorite,
      );
      notifyListeners();
    }
  }
}
