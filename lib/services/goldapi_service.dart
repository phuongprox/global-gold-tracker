import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GoldAPIService {
  static const String _baseUrl = 'https://www.goldapi.io/api';
  static const String _apiKey =
      'goldapi-1f9da0fe16d98e869965997b94797bd6-io'; // 🔑 THAY BẰNG API KEY CỦA BẠN

  // Cache để giảm số lần gọi API
  static Map<String, dynamic>? _cachedPrice;
  static DateTime? _lastFetch;
  static const int _cacheDurationMinutes = 2; // Cache 2 phút

  /// Lấy giá vàng thế giới (XAU/USD)
  Future<Map<String, dynamic>> getGoldPriceWorld() async {
    // Kiểm tra cache
    if (_cachedPrice != null && _lastFetch != null) {
      final diff = DateTime.now().difference(_lastFetch!);
      if (diff.inMinutes < _cacheDurationMinutes) {
        return _cachedPrice!;
      }
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/XAU/USD'),
        headers: {
          'x-access-token': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Lưu cache
        _cachedPrice = data;
        _lastFetch = DateTime.now();

        return data;
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching gold price: $e');

      // Nếu có cache cũ thì trả về cache
      if (_cachedPrice != null) {
        return _cachedPrice!;
      }

      // Fallback to mock data
      return _getMockData();
    }
  }

  /// Lấy giá vàng theo currency (EUR, GBP, JPY, VND...)
  Future<Map<String, dynamic>> getGoldPriceByCurrency(String currency) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/XAU/$currency'),
        headers: {
          'x-access-token': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching gold price for $currency: $e');
      return _getMockData();
    }
  }

  /// Lấy giá bạc thế giới (XAG/USD)
  Future<Map<String, dynamic>> getSilverPriceWorld() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/XAG/USD'),
        headers: {
          'x-access-token': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching silver price: $e');
      return {};
    }
  }

  /// Lấy tỷ giá USD/VND để quy đổi
  Future<double> getUSDtoVND() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates']['VND'] ?? 25450.0;
      }
      return 25450.0;
    } catch (e) {
      print('Error fetching exchange rate: $e');
      return 25450.0;
    }
  }

  /// Lấy giá vàng quy đổi sang VND
  Future<Map<String, dynamic>> getGoldPriceVND() async {
    try {
      // Lấy giá vàng USD
      final goldUSD = await getGoldPriceWorld();
      // Lấy tỷ giá USD/VND
      final usdToVnd = await getUSDtoVND();

      // Giá vàng thế giới tính bằng USD/ounce
      final priceUSD = goldUSD['price'] ?? 2350.0;

      // Quy đổi sang VND/lượng (1 ounce = 0.829 lượng)
      // Công thức: (priceUSD * usdToVnd) / 0.829
      final priceVNDPerLuong = (priceUSD * usdToVnd) / 0.829;

      return {
        'price_usd': priceUSD,
        'price_vnd': priceVNDPerLuong.toInt(),
        'usd_vnd': usdToVnd,
        'change': goldUSD['ch'] ?? 0,
        'change_percent': goldUSD['chp'] ?? 0,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error converting to VND: $e');
      return {
        'price_usd': 2350.50,
        'price_vnd': 17240000,
        'usd_vnd': 25450,
        'change': 12.5,
        'change_percent': 0.53,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  Map<String, dynamic> _getMockData() {
    return {
      'price': 2350.50,
      'currency': 'USD',
      'ch': 12.5,
      'chp': 0.53,
      'ask': 2352.00,
      'bid': 2349.00,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
