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
      appBar: AppBar(
        title: const Text('Giá vàng'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header table
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
              builder: (context, market, _) {
                return ListView.builder(
                  itemCount: market.goldPrices.length,
                  itemBuilder: (context, index) {
                    return PriceCard(
                      name: market.goldPrices[index].name,
                      buyPrice: market.goldPrices[index].buyPrice,
                      sellPrice: market.goldPrices[index].sellPrice,
                      isFavorite: market.goldPrices[index].isFavorite,
                      onFavoriteTap: () => market.toggleFavorite(index),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: TextButton(
              onPressed: () {},
              child: const Text('+ Thêm giá vàng thủ công',
                  style: TextStyle(color: Colors.blue)),
            ),
          ),
        ],
      ),
    );
  }
}
