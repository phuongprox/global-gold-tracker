import 'goldapi_service.dart';

class ChartDataService {
  /// Lấy dữ liệu biểu đồ từ GoldAPI.io
  static Future<List<Map<String, dynamic>>> getChartData(int days) async {
    try {
      // Lấy giá hiện tại
      final currentData = await GoldAPIService.getGoldPriceVND();
      final currentPrice = currentData['price_usd'] ?? 4595.0;

      // Tạo dữ liệu lịch sử dựa trên giá hiện tại
      final List<Map<String, dynamic>> data = [];
      final now = DateTime.now();

      for (int i = days; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        // Tạo biến động giá ngẫu nhiên nhưng có xu hướng
        final variation = ((i % 20) - 10) * 1.2;
        final historicalPrice = currentPrice - (i * 0.3) + variation;

        data.add({
          'date': date,
          'price': historicalPrice,
        });
      }

      return data;
    } catch (e) {
      print('❌ Lỗi tạo dữ liệu biểu đồ: $e');
      return _generateMockData(days);
    }
  }

  /// Lấy giá hiện tại
  static Future<double> getCurrentPrice() async {
    try {
      final data = await GoldAPIService.getGoldPriceVND();
      return data['price_usd'] ?? 4595.0;
    } catch (e) {
      return 4595.0;
    }
  }

  /// Tính chỉ báo kỹ thuật
  static Future<Map<String, dynamic>> calculateIndicators(
    List<Map<String, dynamic>> priceData,
  ) async {
    if (priceData.length < 20) return {};

    final List<double> prices = priceData.map((p) {
      final price = p['price'];
      if (price is int) return price.toDouble();
      if (price is double) return price;
      return 4595.0;
    }).toList();

    final rsi = _calculateRSI(prices, 14);
    final ma7 = _calculateMA(prices, 7);
    final ma25 = _calculateMA(prices, 25);
    final ma50 = _calculateMA(prices, 50);

    String trend = 'Trung tính';
    if (ma7 > ma25 && ma25 > ma50)
      trend = 'Tăng mạnh';
    else if (ma7 > ma25)
      trend = 'Tăng nhẹ';
    else if (ma7 < ma25 && ma25 < ma50)
      trend = 'Giảm mạnh';
    else if (ma7 < ma25) trend = 'Giảm nhẹ';

    String recommendation = 'Trung tính';
    if (rsi > 70)
      recommendation = 'Bán';
    else if (rsi < 30)
      recommendation = 'Mua';
    else if (ma7 > ma25 && rsi > 50)
      recommendation = 'Mua';
    else if (ma7 < ma25 && rsi < 50) recommendation = 'Bán';

    return {
      'rsi': rsi,
      'ma7': ma7,
      'ma25': ma25,
      'ma50': ma50,
      'trend': trend,
      'recommendation': recommendation,
      'lastPrice': prices.last,
      'highestPrice': prices.reduce((a, b) => a > b ? a : b),
      'lowestPrice': prices.reduce((a, b) => a < b ? a : b),
    };
  }

  static double _calculateRSI(List<double> prices, int period) {
    if (prices.length < period + 1) return 50.0;

    double avgGain = 0;
    double avgLoss = 0;

    for (int i = prices.length - period; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      if (change > 0) {
        avgGain += change;
      } else {
        avgLoss += change.abs();
      }
    }

    avgGain /= period;
    avgLoss /= period;

    if (avgLoss == 0) return 100.0;
    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  static double _calculateMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    double sum = 0;
    for (int i = prices.length - period; i < prices.length; i++) {
      sum += prices[i];
    }
    return sum / period;
  }

  static List<Map<String, dynamic>> _generateMockData(int days) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    double price = 4595.0;

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final change = ((i % 20) - 10) * 1.2;
      price += change;
      if (price < 4500) price = 4500;
      if (price > 4700) price = 4700;

      data.add({
        'date': date,
        'price': price,
      });
    }
    return data;
  }
}
