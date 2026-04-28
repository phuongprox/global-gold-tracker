import 'dart:math';

class ChartDataService {
  // Tạo dữ liệu giá ngẫu nhiên nhưng theo xu hướng thực tế
  static List<Map<String, dynamic>> generateGoldPriceData(int days) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    final random = Random();

    // Giá cơ sở (tham khảo giá thực tế)
    double basePrice = 2350.0; // USD/ounce
    double trend = 0; // Xu hướng

    for (int i = days; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Tạo biến động ngẫu nhiên nhưng có xu hướng
      final volatility = (random.nextDouble() - 0.5) * 15;
      trend += (random.nextDouble() - 0.48) * 1.5;

      double open = basePrice + trend + volatility;
      double close = open + (random.nextDouble() - 0.5) * 12;

      // SỬA: Dùng toán tử thay vì hàm max/min
      double high = open > close ? open : close;
      high = high + random.nextDouble() * 10;

      double low = open < close ? open : close;
      low = low - random.nextDouble() * 10;

      // Đảm bảo giá dương
      if (open < 2300) open = 2300;
      if (close < 2300) close = 2300;
      if (high < open) high = open;
      if (low < 2300) low = 2300;

      data.add({
        'date': date,
        'open': open,
        'high': high,
        'low': low,
        'close': close,
        'volume': 100000 + random.nextInt(50000),
      });

      basePrice = close;
    }

    return data;
  }

  // Tạo dữ liệu cho biểu đồ đường (đơn giản hơn)
  static List<Map<String, dynamic>> generateLineChartData(int points) {
    final List<Map<String, dynamic>> data = [];
    final now = DateTime.now();
    final random = Random();

    double price = 2350.0;

    for (int i = points; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Biến động giá
      final change = (random.nextDouble() - 0.48) * 8;
      price += change;

      // SỬA: Dùng if thay vì max/min
      if (price < 2300) price = 2300;
      if (price > 2450) price = 2450;

      data.add({
        'date': date,
        'price': price,
        'volume': 50000 + random.nextInt(30000),
      });
    }

    return data;
  }

  // Tính toán các chỉ báo kỹ thuật cơ bản
  static Map<String, dynamic> calculateIndicators(
      List<Map<String, dynamic>> priceData) {
    if (priceData.length < 20) return {};

    // SỬA: Lấy danh sách price an toàn
    final List<double> prices = [];
    for (var p in priceData) {
      if (p['close'] != null) {
        prices.add(p['close'].toDouble());
      } else if (p['price'] != null) {
        prices.add(p['price'].toDouble());
      }
    }

    if (prices.length < 20) return {};

    // RSI (14)
    final rsi = calculateRSI(prices, 14);

    // MA 7, 25, 50
    final ma7 = calculateMA(prices, 7);
    final ma25 = calculateMA(prices, 25);
    final ma50 = calculateMA(prices, 50);

    // Xu hướng
    String trend = 'Trung tính';
    if (ma7 > ma25 && ma25 > ma50) {
      trend = 'Tăng mạnh';
    } else if (ma7 > ma25) {
      trend = 'Tăng nhẹ';
    } else if (ma7 < ma25 && ma25 < ma50) {
      trend = 'Giảm mạnh';
    } else if (ma7 < ma25) {
      trend = 'Giảm nhẹ';
    }

    // Khuyến nghị
    String recommendation = 'Trung tính';
    if (rsi > 70) {
      recommendation = 'Bán';
    } else if (rsi < 30) {
      recommendation = 'Mua';
    } else if (ma7 > ma25 && rsi > 50) {
      recommendation = 'Mua';
    } else if (ma7 < ma25 && rsi < 50) {
      recommendation = 'Bán';
    }

    // Tìm giá trị lớn nhất và nhỏ nhất
    double highest = prices[0];
    double lowest = prices[0];
    for (var p in prices) {
      if (p > highest) highest = p;
      if (p < lowest) lowest = p;
    }

    return {
      'rsi': rsi,
      'ma7': ma7,
      'ma25': ma25,
      'ma50': ma50,
      'trend': trend,
      'recommendation': recommendation,
      'lastPrice': prices.last,
      'highestPrice': highest,
      'lowestPrice': lowest,
    };
  }

  static double calculateRSI(List<double> prices, int period) {
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

  static double calculateMA(List<double> prices, int period) {
    if (prices.length < period) return prices.last;

    double sum = 0;
    for (int i = prices.length - period; i < prices.length; i++) {
      sum += prices[i];
    }
    return sum / period;
  }
}
