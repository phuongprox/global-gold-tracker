import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/market_provider.dart';
import '../widgets/price_card.dart';

class GoldScreen extends StatelessWidget {
  const GoldScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Expanded(
                    flex: 3,
                    child: Text('TÊN SẢN PHẨM',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    flex: 2,
                    child: Text('GIÁ MUA',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green))),
                Expanded(
                    flex: 2,
                    child: Text('GIÁ BÁN',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.red))),
                const SizedBox(width: 20),
              ],
            ),
          ),
          const Divider(height: 0),
          Expanded(
            child: Consumer<MarketProvider>(
              builder: (context, marketProvider, _) {
                if (marketProvider.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.amber));
                }
                return ListView.builder(
                  itemCount: marketProvider.goldPrices.length,
                  itemBuilder: (context, index) {
                    return PriceCard(
                      name: marketProvider.goldPrices[index].name,
                      buyPrice: marketProvider.goldPrices[index].buyPrice,
                      sellPrice: marketProvider.goldPrices[index].sellPrice,
                      isFavorite: marketProvider.goldPrices[index].isFavorite,
                      isWorldPrice:
                          marketProvider.goldPrices[index].isWorldPrice,
                      onFavoriteTap: () => marketProvider.toggleFavorite(index),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
