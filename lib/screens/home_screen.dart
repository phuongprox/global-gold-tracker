import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../providers/portfolio_provider.dart';
import '../widgets/asset_card.dart';
import '../widgets/price_card.dart';
import '../widgets/gold_chart_widget.dart';
import '../widgets/live_ticker.dart';
import '../widgets/world_gold_price_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final marketProvider =
                Provider.of<MarketProvider>(context, listen: false);
            await marketProvider.refreshPrices();
          },
          color: Colors.amber,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LiveTicker(),
                const SizedBox(height: 16),
                const WorldGoldPriceCard(),
                const SizedBox(height: 16),
                const Text(
                  'Số vàng',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                                      '${formatPrice(portfolio.totalCost)} đ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                      '${formatPrice(portfolio.currentValue)} đ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                '${portfolio.profit >= 0 ? '+' : ''}${formatPrice(portfolio.profit)} đ (${portfolio.profitPercentage.toStringAsFixed(1)}%)',
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('Tính năng đang phát triển')),
                ),
                const SizedBox(height: 16),
                const Text('Ứng hộ Tích Chỉ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Giá vàng',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/gold');
                      },
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Consumer<MarketProvider>(
                  builder: (context, marketProvider, _) {
                    if (marketProvider.isLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(color: Colors.amber),
                        ),
                      );
                    }
                    final featuredPrices = marketProvider.featuredPrices;
                    if (featuredPrices.isEmpty) {
                      return const Center(
                          child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Không có dữ liệu'),
                      ));
                    }
                    return Column(
                      children: featuredPrices.map((price) {
                        return PriceCard(
                          name: price.name,
                          buyPrice: price.buyPrice,
                          sellPrice: price.sellPrice,
                          isFavorite: price.isFavorite,
                          isWorldPrice: price.isWorldPrice,
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                const GoldChartWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
