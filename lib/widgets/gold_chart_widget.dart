import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/chart_data_service.dart';
import 'dart:math'; // THÊM IMPORT NÀY

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
  double _currentPrice = 2350;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  void _loadChartData() {
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

    final data = ChartDataService.generateLineChartData(days);
    _indicators = ChartDataService.calculateIndicators(
        data.map((d) => {'close': d['price']}).toList());

    _chartSpots = data.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value['price']);
    }).toList();

    if (_chartSpots.isNotEmpty) {
      _currentPrice = _chartSpots.last.y;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Tính minY và maxY an toàn
    double minY = 2300;
    double maxY = 2450;

    if (_chartSpots.isNotEmpty) {
      final yValues = _chartSpots.map((s) => s.y).toList();
      double minVal = yValues[0];
      double maxVal = yValues[0];

      for (var val in yValues) {
        if (val < minVal) minVal = val;
        if (val > maxVal) maxVal = val;
      }

      minY = minVal - 10;
      maxY = maxVal + 10;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Biểu đồ giá vàng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Phân tích AI',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          // Giá hiện tại
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Giá hiện tại: ',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '\$${_currentPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Range selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _ranges.map((range) {
                final isSelected = _selectedRange == range;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRange = range;
                      _loadChartData();
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.grey.shade300,
                      ),
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
            child: _chartSpots.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  )
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
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (_chartSpots.isEmpty) return const Text('');
                                final index = value.toInt();
                                if (index < 0 || index >= _chartSpots.length) {
                                  return const Text('');
                                }
                                if (index % (_chartSpots.length ~/ 5) != 0) {
                                  return const Text('');
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade500,
                                    ),
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
                                    color: Colors.grey.shade500,
                                  ),
                                );
                              },
                              reservedSize: 45,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border:
                              Border.all(color: Colors.grey.shade200, width: 1),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _chartSpots,
                            isCurved: true,
                            color: Colors.amber,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.amber.withOpacity(0.1),
                            ),
                          ),
                        ],
                        minX: 0,
                        maxX: _chartSpots.isEmpty
                            ? 1
                            : (_chartSpots.length - 1).toDouble(),
                        minY: minY,
                        maxY: maxY,
                      ),
                    ),
                  ),
          ),

          const SizedBox(height: 16),

          // Thông tin chỉ báo
          if (_indicators.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    'RSI',
                    _indicators['rsi']?.toStringAsFixed(1) ?? '--',
                    _getRSIColor(_indicators['rsi'] ?? 50),
                  ),
                  _buildInfoItem(
                    'MA7',
                    '\$${_indicators['ma7']?.toStringAsFixed(0) ?? '--'}',
                    Colors.grey,
                  ),
                  _buildInfoItem(
                    'MA25',
                    '\$${_indicators['ma25']?.toStringAsFixed(0) ?? '--'}',
                    Colors.grey,
                  ),
                  _buildInfoItem(
                    'Xu hướng',
                    _indicators['trend'] ?? '--',
                    _getTrendColor(_indicators['trend'] ?? 'Trung tính'),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
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
}
