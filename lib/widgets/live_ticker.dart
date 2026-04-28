import 'package:flutter/material.dart';

class LiveTicker extends StatefulWidget {
  const LiveTicker({Key? key}) : super(key: key);

  @override
  State<LiveTicker> createState() => _LiveTickerState();
}

class _LiveTickerState extends State<LiveTicker> {
  final List<Map<String, dynamic>> _tickerItems = [
    {
      'name': 'Vàng SJC',
      'price': '17,240,000',
      'change': '+12,000',
      'isUp': true
    },
    {
      'name': 'Vàng nhẫn PNJ',
      'price': '17,220,000',
      'change': '+8,000',
      'isUp': true
    },
    {
      'name': 'Vàng thế giới',
      'price': '2,350.50',
      'change': '-5.20',
      'isUp': false
    },
    {'name': 'USD/VND', 'price': '25,450', 'change': '+15', 'isUp': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.amber.shade50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _tickerItems.length * 2, // Chạy vòng lặp
        itemBuilder: (context, index) {
          final item = _tickerItems[index % _tickerItems.length];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 8),
                Text(
                  item['price'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(width: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: item['isUp'] ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item['isUp']
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 10,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        item['change'],
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
