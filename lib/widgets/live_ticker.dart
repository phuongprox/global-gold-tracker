import 'package:flutter/material.dart';
import 'dart:async';
import 'package:marquee/marquee.dart';
import '../services/goldapi_service.dart';

class LiveTicker extends StatefulWidget {
  const LiveTicker({Key? key}) : super(key: key);

  @override
  State<LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<LiveTicker> {
  late Timer _timer;
  List<Map<String, dynamic>> _tickerItems = [];
  bool _isLoading = true;
  String _tickerText = '';

  @override
  void initState() {
    super.initState();
    _loadTickerData();
    // Cập nhật mỗi 15 giây
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _loadTickerData();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadTickerData() async {
    try {
      print('🔄 Đang tải dữ liệu Live Ticker...');

      final goldData = await GoldAPIService.getGoldPriceVND();
      print('✅ Giá vàng thế giới: ${goldData['price_usd']} USD');

      final List<Map<String, dynamic>> newItems = [];

      // 1. Vàng thế giới
      newItems.add({
        'name': 'Vàng TG',
        'price': goldData['price_usd'],
        'change': goldData['change_percent'],
        'isUp': goldData['change_percent'] >= 0,
        'currency': 'USD',
      });

      // 2. Vàng SJC (quy đổi)
      final vndPrice = goldData['price_vnd'] ?? 17240000;
      newItems.add({
        'name': 'Vàng SJC',
        'price': vndPrice,
        'change': 0.12,
        'isUp': true,
        'currency': 'VND',
      });

      // 3. Bạc thế giới (ước tính)
      newItems.add({
        'name': 'Bạc TG',
        'price': goldData['price_usd'] / 85, // Tỷ lệ vàng/bạc ~85
        'change': -0.08,
        'isUp': false,
        'currency': 'USD',
      });

      // 4. USD/VND
      final usdRate = goldData['usd_vnd'] ?? 25450;
      newItems.add({
        'name': 'USD/VND',
        'price': usdRate,
        'change': 0.03,
        'isUp': true,
        'currency': 'RATE',
      });

      setState(() {
        _tickerItems = newItems;
        _isLoading = false;
        _updateTickerText();
      });

      print('✅ Live Ticker cập nhật thành công');
    } catch (e) {
      print('❌ Lỗi Live Ticker: $e');
      setState(() {
        _isLoading = false;
        _tickerItems = [
          {
            'name': 'Vàng TG',
            'price': 4595.50,
            'change': 0.27,
            'isUp': true,
            'currency': 'USD'
          },
          {
            'name': 'Vàng SJC',
            'price': 92400000,
            'change': 0.15,
            'isUp': true,
            'currency': 'VND'
          },
          {
            'name': 'Bạc TG',
            'price': 28.50,
            'change': -0.08,
            'isUp': false,
            'currency': 'USD'
          },
          {
            'name': 'USD/VND',
            'price': 25450,
            'change': 0.05,
            'isUp': true,
            'currency': 'RATE'
          },
        ];
        _updateTickerText();
      });
    }
  }

  void _updateTickerText() {
    final buffer = StringBuffer();
    for (var item in _tickerItems) {
      final arrow = item['isUp'] ? '▲' : '▼';
      final changeColor = item['isUp'] ? '+' : '';

      String priceStr;
      if (item['currency'] == 'USD') {
        priceStr = '\$${item['price'].toStringAsFixed(2)}';
      } else if (item['currency'] == 'VND') {
        priceStr = item['price'].toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]}.',
            );
      } else {
        priceStr = item['price'].toString();
      }

      buffer.write(
          '  ${item['name']}  $priceStr  $arrow ${changeColor}${item['change'].toStringAsFixed(2)}%   |');
    }
    _tickerText = buffer.toString();
  }

  String _formatChange(double change) {
    return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 40,
        color: Colors.amber.shade50,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.amber),
          ),
        ),
      );
    }

    return Container(
      height: 40,
      color: Colors.amber.shade50,
      child: Marquee(
        text: _tickerText,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          height: 1.2,
        ),
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: 50.0,
        velocity: 40.0, // Tốc độ chạy (càng cao càng nhanh)
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(milliseconds: 500),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
