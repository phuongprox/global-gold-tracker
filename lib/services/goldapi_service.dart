import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldAPIService {
  // 👇 THAY API KEY CỦA BẠN VÀO ĐÂY
  static const String _apiKey = 'goldapi-1f9da0fe16d98e869965997b94797bd6-io';
  static const String _baseUrl = 'https://www.goldapi.io/api';

  static Map<String, dynamic>? _cachedPrice;
  static DateTime? _lastFetch;
  static const int _cacheDurationMinutes = 2;

  static Future<Map<String, dynamic>> getGoldPriceWorld() async {
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
        _cachedPrice = data;
        _lastFetch = DateTime.now();
        return data;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi lấy giá vàng: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getGoldPriceVND() async {
    try {
      final goldUSD = await getGoldPriceWorld();
      final usdToVnd = await _getUSDtoVND();

      final priceUSD = goldUSD['price'] ?? 4595.0;
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
      print('❌ Lỗi quy đổi: $e');
      return {
        'price_usd': 4595.50,
        'price_vnd': 17240000,
        'usd_vnd': 25450,
        'change': 12.5,
        'change_percent': 0.27,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  static Future<double> _getUSDtoVND() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['rates']['VND']?.toDouble() ?? 25450.0;
      }
      return 25450.0;
    } catch (e) {
      print('Lỗi lấy tỷ giá: $e');
      return 25450.0;
    }
  }
}
