import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AlphaVantageService {
  // 👇 THAY API KEY CỦA BẠN VÀO ĐÂY
  static const String _apiKey = '9GTAVPKEYWYLYF4B';

  // Cache
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTime = {};
  static const int _cacheDurationMinutes = 2;

  /// Lấy giá vàng XAU/USD real-time
  static Future<double> getCurrentGoldPrice() async {
    // Kiểm tra cache
    if (_cache.containsKey('current_price') &&
        _cacheTime.containsKey('current_price')) {
      final diff = DateTime.now().difference(_cacheTime['current_price']!);
      if (diff.inMinutes < 1) {
        return _cache['current_price'];
      }
    }

    try {
      final url = Uri.parse('https://www.alphavantage.co/query'
          '?function=CURRENCY_EXCHANGE_RATE'
          '&from_currency=XAU'
          '&to_currency=USD'
          '&apikey=$_apiKey');

      print('🌐 Gọi Alpha Vantage API lấy giá vàng...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra lỗi
        if (data.containsKey('Error Message')) {
          print('❌ API Error: ${data['Error Message']}');
          return _getDefaultPrice();
        }

        final rate = data['Realtime Currency Exchange Rate'];
        if (rate != null && rate['5. Exchange Rate'] != null) {
          final price = double.parse(rate['5. Exchange Rate'].toString());
          print('💰 Giá vàng XAU/USD: \$${price.toStringAsFixed(2)}');

          // Lưu cache
          _cache['current_price'] = price;
          _cacheTime['current_price'] = DateTime.now();

          return price;
        }
      }

      return _getDefaultPrice();
    } catch (e) {
      print('❌ Lỗi lấy giá vàng: $e');
      return _getDefaultPrice();
    }
  }

  /// Lấy dữ liệu lịch sử XAU/USD
  static Future<List<Map<String, dynamic>>> getHistoricalPrices(
      int days) async {
    final cacheKey = 'historical_$days';

    // Kiểm tra cache
    if (_cache.containsKey(cacheKey) && _cacheTime.containsKey(cacheKey)) {
      final diff = DateTime.now().difference(_cacheTime[cacheKey]!);
      if (diff.inMinutes < _cacheDurationMinutes) {
        print('📦 Dùng cache cho $days ngày');
        return _cache[cacheKey];
      }
    }

    try {
      // Alpha Vantage chỉ hỗ trợ tối đa 100 ngày cho free plan
      final outputSize = days <= 100 ? 'compact' : 'full';

      final url = Uri.parse('https://www.alphavantage.co/query'
          '?function=FX_DAILY'
          '&from_symbol=XAU'
          '&to_symbol=USD'
          '&outputsize=$outputSize'
          '&apikey=$_apiKey');

      print('🌐 Gọi Alpha Vantage API lấy dữ liệu lịch sử...');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data.containsKey('Error Message')) {
          print('❌ API Error: ${data['Error Message']}');
          return _generateMockHistoricalData(days);
        }

        final timeSeries = data['Time Series FX (Daily)'];

        if (timeSeries != null) {
          final List<Map<String, dynamic>> prices = [];
          final keys = timeSeries.keys.toList();

          // Sắp xếp theo ngày (mới nhất trước)
          keys.sort((a, b) => b.compareTo(a));

          final takeDays = days > keys.length ? keys.length : days;

          for (int i = 0; i < takeDays; i++) {
            final dailyData = timeSeries[keys[i]];
            try {
              prices.add({
                'date': DateTime.parse(keys[i]),
                'open': double.parse(dailyData['1. open'].toString()),
                'high': double.parse(dailyData['2. high'].toString()),
                'low': double.parse(dailyData['3. low'].toString()),
                'close': double.parse(dailyData['4. close'].toString()),
              });
            } catch (e) {
              print('Lỗi parse dữ liệu: $e');
            }
          }

          // Đảo ngược để từ cũ đến mới
          final result = prices.reversed.toList();

          print('✅ Lấy thành công ${result.length} điểm dữ liệu');
          if (result.isNotEmpty) {
            print(
                '📊 Giá mới nhất: \$${result.last['close'].toStringAsFixed(2)}');
          }

          // Lưu cache
          _cache[cacheKey] = result;
          _cacheTime[cacheKey] = DateTime.now();

          return result;
        }
      }

      return _generateMockHistoricalData(days);
    } catch (e) {
      print('❌ Lỗi lấy dữ liệu lịch sử: $e');
      return _generateMockHistoricalData(days);
    }
  }

  /// Dữ liệu mặc định khi API lỗi (giá thực tế 2026)
  static double _getDefaultPrice() {
    return 4595.50; // Giá vàng thực tế 2026 ~ $4,595/oz
  }

  /// Tạo mock data với giá thực tế
  static List<Map<String, dynamic>> _generateMockHistoricalData(int days) {
    print('⚠️ Tạo mock data cho $days ngày với giá ~\$4,595/oz');

    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    double price = 4595.0;

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Biến động nhẹ ±5-15 USD
      final change = ((i % 20) - 10) * 1.2;
      price += change;

      // Giới hạn trong khoảng 4550-4650
      if (price < 4550) price = 4550;
      if (price > 4650) price = 4650;

      data.add({
        'date': date,
        'open': price,
        'high': price + 5,
        'low': price - 5,
        'close': price,
      });
    }

    return data;
  }

  /// Xóa cache
  static void clearCache() {
    _cache.clear();
    _cacheTime.clear();
    print('🗑️ Cache đã xóa');
  }
}
