import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/chart_data_service.dart';

class GoldChartWidget extends StatefulWidget {
  const GoldChartWidget({Key? key}) : super(key: key);

  @override
  State<GoldChartWidget> createState() => _GoldChartWidgetState();
}

class _GoldChartWidgetState extends State<GoldChartWidget> {
  String _selectedRange = '1M';
  final List<String> _ranges = ['1W', '1M', '3M', '6M', '1Y'];

  List<FlSpot> _chartSpots = [];
  Map<String, dynamic> _indicators = {};
  double _currentPrice = 4595;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRealChartData();
  }

  Future<void> _loadRealChartData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int days = 30;
      switch (_selectedRange) {
        case '1W':
          days = 7;
          break;
        case '1M':
          days = 30;
          break;
        case '3M':
          days = 90;
          break;
        case '6M':
          days = 180;
          break;
        case '1Y':
          days = 365;
          break;
      }

      final rawData = await ChartDataService.getChartData(days);

      if (rawData.isEmpty) {
        throw Exception('No data');
      }

      _chartSpots = rawData.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value['price']);
      }).toList();

      _currentPrice = rawData.last['price'];
      _indicators = await ChartDataService.calculateIndicators(rawData);

      print(
          '✅ Đã tải ${rawData.length} điểm, giá: \$${_currentPrice.toStringAsFixed(2)}');

      setState(() {});
    } catch (e) {
      print('❌ Lỗi: $e');
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double minY = 4500;
    double maxY = 4700;

    if (_chartSpots.isNotEmpty) {
      final yValues = _chartSpots.map((s) => s.y).toList();
      minY = yValues.reduce((a, b) => a < b ? a : b) - 20;
      maxY = yValues.reduce((a, b) => a > b ? a : b) + 20;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Giá vàng thế giới',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (_isLoading)
                          const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                        else
                          Text(
                            '\$${_currentPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                        const SizedBox(width: 4),
                        const Text('USD/oz',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isLoading
                        ? Colors.grey
                        : (_errorMessage != null ? Colors.red : Colors.green),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isLoading
                        ? 'Đang tải...'
                        : (_errorMessage != null ? 'Lỗi' : 'Live'),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 12)),
            ),

          const SizedBox(height: 8),

          // Range selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _ranges.map((range) {
                final isSelected = _selectedRange == range;
                return GestureDetector(
                  onTap: !_isLoading
                      ? () {
                          setState(() => _selectedRange = range);
                          _loadRealChartData();
                        }
                      : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              isSelected ? Colors.amber : Colors.grey.shade300),
                    ),
                    child: Text(
                      range,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Chart
          SizedBox(
            height: 220,
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber))
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            Text('Không thể tải dữ liệu',
                                style: TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadRealChartData,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _chartSpots.isEmpty
                        ? const Center(child: Text('Không có dữ liệu'))
                        : Padding(
                            padding: const EdgeInsets.only(right: 16, left: 8),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                        color: Colors.grey.shade200,
                                        strokeWidth: 1);
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        if (_chartSpots.isEmpty)
                                          return const Text('');
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= _chartSpots.length)
                                          return const Text('');
                                        if (index % (_chartSpots.length ~/ 5) !=
                                            0) return const Text('');
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade500),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '\$${value.toInt()}',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade500),
                                        );
                                      },
                                      reservedSize: 50,
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                      color: Colors.grey.shade200, width: 1),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: _chartSpots,
                                    isCurved: true,
                                    color: Colors.amber,
                                    barWidth: 2,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.amber.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                                minX: 0,
                                maxX: (_chartSpots.length - 1).toDouble(),
                                minY: minY,
                                maxY: maxY,
                              ),
                            ),
                          ),
          ),

          // 👉 THÊM LẠI PHẦN CHỈ BÁO KỸ THUẬT
          if (!_isLoading && _errorMessage == null && _indicators.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    '📊 Phân tích kỹ thuật',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIndicatorItem(
                          'RSI (14)',
                          _indicators['rsi']?.toStringAsFixed(1) ?? '--',
                          _getRSIColor(_indicators['rsi'] ?? 50)),
                      _buildIndicatorItem(
                          'MA7',
                          '\$${_indicators['ma7']?.toStringAsFixed(0) ?? '--'}',
                          Colors.blue),
                      _buildIndicatorItem(
                          'MA25',
                          '\$${_indicators['ma25']?.toStringAsFixed(0) ?? '--'}',
                          Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildIndicatorItem(
                          'MA50',
                          '\$${_indicators['ma50']?.toStringAsFixed(0) ?? '--'}',
                          Colors.blue),
                      _buildIndicatorItem(
                          'Xu hướng',
                          _indicators['trend'] ?? '--',
                          _getTrendColor(_indicators['trend'] ?? 'Trung tính')),
                      _buildIndicatorItem(
                          'Khuyến nghị',
                          _indicators['recommendation'] ?? '--',
                          _getRecommendationColor(
                              _indicators['recommendation'] ?? 'Trung tính')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getRecommendationColor(
                              _indicators['recommendation'] ?? 'Trung tính')
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _indicators['recommendation'] == 'Mua'
                              ? Icons.trending_up
                              : _indicators['recommendation'] == 'Bán'
                                  ? Icons.trending_down
                                  : Icons.remove,
                          color: _getRecommendationColor(
                              _indicators['recommendation'] ?? 'Trung tính'),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getRecommendationMessage(
                              _indicators['recommendation'] ?? 'Trung tính'),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRecommendationColor(
                                _indicators['recommendation'] ?? 'Trung tính'),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getRSIColor(double rsi) {
    if (rsi > 70) return Colors.red;
    if (rsi < 30) return Colors.green;
    return Colors.orange;
  }

  Color _getTrendColor(String trend) {
    if (trend.contains('Tăng')) return Colors.green;
    if (trend.contains('Giảm')) return Colors.red;
    return Colors.orange;
  }

  Color _getRecommendationColor(String recommendation) {
    if (recommendation == 'Mua') return Colors.green;
    if (recommendation == 'Bán') return Colors.red;
    return Colors.orange;
  }

  String _getRecommendationMessage(String recommendation) {
    switch (recommendation) {
      case 'Mua':
        return '💰 Nên mua vàng trong thời điểm này';
      case 'Bán':
        return '⚠️ Cân nhắc bán vàng để chốt lời';
      default:
        return '📊 Giữ quan sát, chưa có tín hiệu rõ ràng';
    }
  }
}
