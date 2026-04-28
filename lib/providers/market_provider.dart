import 'package:flutter/material.dart';
import '../models/gold_price.dart';

class MarketProvider extends ChangeNotifier {
  // Danh sách giá vàng từ màn hình thứ 2
  List<GoldPrice> _goldPrices = [
    GoldPrice(
        name: 'Vàng nhẫn Bảo Tín Mạnh Hải',
        buyPrice: 16970000,
        sellPrice: 17270000),
    GoldPrice(
        name: 'Vàng miếng SJC',
        buyPrice: 16940000,
        sellPrice: 17240000,
        isFavorite: true),
    GoldPrice(
        name: 'Vàng nhẫn Bảo Tín Minh Châu',
        buyPrice: 16940000,
        sellPrice: 17240000),
    GoldPrice(
        name: 'Vàng nhẫn Doji',
        buyPrice: 16940000,
        sellPrice: 17240000,
        isFavorite: true),
    GoldPrice(
        name: 'Vàng nhẫn Huy Thanh', buyPrice: 16940000, sellPrice: 17240000),
    GoldPrice(
        name: 'Vàng nhẫn Mi Hồng', buyPrice: 17070000, sellPrice: 17240000),
    GoldPrice(
        name: 'Vàng nhẫn Phú Quý', buyPrice: 16920000, sellPrice: 17220000),
    GoldPrice(name: 'Vàng nhẫn PNJ', buyPrice: 16920000, sellPrice: 17220000),
    GoldPrice(
        name: 'Vàng nhẫn Cashion', buyPrice: 16920000, sellPrice: 17210000),
    GoldPrice(
        name: 'Vàng nhẫn SJC',
        buyPrice: 16910000,
        sellPrice: 17210000,
        isFavorite: true),
    GoldPrice(
        name: 'Vàng nhẫn Ancarat', buyPrice: 16790000, sellPrice: 17090000),
    GoldPrice(name: 'Vàng nhẫn SBJ', buyPrice: 16720000, sellPrice: 17010000),
    GoldPrice(
        name: 'Vàng nhẫn Ngọc Thẩm', buyPrice: 15800000, sellPrice: 16200000),
    GoldPrice(
        name: 'Vàng nhẫn Kim Ngân Phúc',
        buyPrice: 15770000,
        sellPrice: 16070000),
    GoldPrice(
        name: 'Vàng nhẫn địa phương', buyPrice: 15800000, sellPrice: 16000000),
    GoldPrice(name: 'Vàng nhẫn HJC', buyPrice: 15710000, sellPrice: 16000000),
  ];

  List<GoldPrice> get goldPrices => _goldPrices;

  // Lấy 3 giá vàng nổi bật cho màn hình chính
  List<GoldPrice> get featuredPrices => _goldPrices.take(3).toList();

  void toggleFavorite(int index) {
    _goldPrices[index] = GoldPrice(
      name: _goldPrices[index].name,
      buyPrice: _goldPrices[index].buyPrice,
      sellPrice: _goldPrices[index].sellPrice,
      isFavorite: !_goldPrices[index].isFavorite,
    );
    notifyListeners();
  }
}
