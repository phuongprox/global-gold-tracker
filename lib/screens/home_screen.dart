import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/asset_card.dart';
import '../widgets/price_card.dart';
import '../widgets/chart_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text('Số vàng',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Asset Cards - Vàng
              Consumer<PortfolioProvider>(
                builder: (context, portfolio, _) {
                  return Column(
                    children: [
                      AssetCard(
                        title: 'Vàng',
                        amount:
                            '${portfolio.totalQuantity.toStringAsFixed(2)} chỉ',
                        subtitle:
                            'Tích lũy: ${portfolio.transactions.length} lần',
                        icon: Icons.workspace_premium,
                        color: Colors.amber,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Tổng chi phí',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                      '${portfolio.totalCost.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Giá trị hiện tại',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                      '${portfolio.currentValue.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: portfolio.profit >= 0
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Lãi/Lỗ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${portfolio.profit >= 0 ? '+' : ''}${portfolio.profit.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} đ (${portfolio.profitPercentage.toStringAsFixed(1)}%)',
                              style: TextStyle(
                                color: portfolio.profit >= 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              const Text('Bạc',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(child: Text('Chưa có dữ liệu bạc')),
              ),

              const SizedBox(height: 16),

              // Ứng hộ Tích Chỉ
              const Text('Ứng hộ Tích Chỉ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Giá vàng section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giá vàng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () {
                      // Navigate to gold screen
                      Navigator.pushNamed(context, '/gold');
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),

              Consumer<MarketProvider>(
                builder: (context, market, _) {
                  return Column(
                    children: market.featuredPrices.map((price) {
                      return PriceCard(
                        name: price.name,
                        buyPrice: price.buyPrice,
                        sellPrice: price.sellPrice,
                        isFavorite: price.isFavorite,
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Chart
              const ChartWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
