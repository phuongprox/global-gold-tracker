import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AdvancedChartScreen extends StatefulWidget {
  const AdvancedChartScreen({Key? key}) : super(key: key);

  @override
  State<AdvancedChartScreen> createState() => _AdvancedChartScreenState();
}

class _AdvancedChartScreenState extends State<AdvancedChartScreen> {
  bool _showRSI = true;
  bool _showMACD = true;
  bool _showBollinger = false;

  // Dữ liệu mẫu cho biểu đồ
  final List<FlSpot> _priceSpots = [
    const FlSpot(0, 169),
    const FlSpot(1, 170),
    const FlSpot(2, 171),
    const FlSpot(3, 170.5),
    const FlSpot(4, 172),
    const FlSpot(5, 171.5),
    const FlSpot(6, 173),
    const FlSpot(7, 174),
    const FlSpot(8, 173.5),
    const FlSpot(9, 175),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích kỹ thuật'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showIndicatorSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicator toggles
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildIndicatorButton('RSI', _showRSI, () {
                  setState(() => _showRSI = !_showRSI);
                }),
                _buildIndicatorButton('MACD', _showMACD, () {
                  setState(() => _showMACD = !_showMACD);
                }),
                _buildIndicatorButton('Bollinger', _showBollinger, () {
                  setState(() => _showBollinger = !_showBollinger);
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: true),
                    titlesData: const FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _priceSpots,
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
                  ),
                ),
              ),
            ),
          ),

          // Technical summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Tóm tắt chỉ báo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildIndicatorSummary(
                    'RSI (14)', '62.5', 'Trung tính', Colors.orange),
                const Divider(),
                _buildIndicatorSummary(
                    'MACD (12,26,9)', 'Bullish', 'Mua mạnh', Colors.green),
                const Divider(),
                _buildIndicatorSummary(
                    'MA (50)', '172.5', 'Hỗ trợ', Colors.blue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorButton(String name, bool isActive, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.amber : Colors.grey,
        foregroundColor: Colors.white,
      ),
      child: Text(name),
    );
  }

  Widget _buildIndicatorSummary(
      String name, String value, String signal, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child:
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              signal,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showIndicatorSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Cài đặt chỉ báo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('RSI (14)'),
              value: _showRSI,
              onChanged: (value) => setState(() => _showRSI = value),
            ),
            SwitchListTile(
              title: const Text('MACD (12, 26, 9)'),
              value: _showMACD,
              onChanged: (value) => setState(() => _showMACD = value),
            ),
            SwitchListTile(
              title: const Text('Bollinger Bands (20, 2)'),
              value: _showBollinger,
              onChanged: (value) => setState(() => _showBollinger = value),
            ),
          ],
        ),
      ),
    );
  }
}
