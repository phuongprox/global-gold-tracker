import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../models/transaction.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sổ vàng'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolio, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Vàng statistics
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Text('Vàng',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Tổng chi phí',
                                    style: TextStyle(color: Colors.grey)),
                                Text('${formatPrice(portfolio.totalCost)} đ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'TB/chỉ: ${formatPrice(portfolio.totalCost ~/ (portfolio.totalQuantity > 0 ? portfolio.totalQuantity : 1))} đ',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Giá trị hiện tại',
                                    style: TextStyle(color: Colors.grey)),
                                Text('${formatPrice(portfolio.currentValue)} đ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'TB/chỉ: ${formatPrice(portfolio.currentGoldPrice)} đ',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Tổng số lượng',
                                    style: TextStyle(color: Colors.grey)),
                                Text(
                                    '${portfolio.totalQuantity.toStringAsFixed(2)} chỉ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Tích lũy',
                                    style: TextStyle(color: Colors.grey)),
                                Text('${portfolio.transactions.length} lần',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Lãi',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${portfolio.profit >= 0 ? '+' : ''}${formatPrice(portfolio.profit)} đ (${portfolio.profitPercentage.toStringAsFixed(1)}%)',
                            style: TextStyle(
                              color: portfolio.profit >= 0
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bạc section
                const Text('Bạc',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Lịch sử tích lũy
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Lịch sử tích lũy',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        TextButton(
                            onPressed: () {}, child: const Text('Mặc định')),
                        const SizedBox(width: 8),
                        TextButton(
                            onPressed: () {}, child: const Text('Chọn bộ lọc')),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (portfolio.transactions.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.account_balance_wallet_outlined,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('Chưa có tích lũy nào',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/add_transaction');
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm tích lũy đầu tiên'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: portfolio.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = portfolio.transactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                tx.type == 'BUY' ? Colors.green : Colors.red,
                            child: Icon(
                                tx.type == 'BUY'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: Colors.white),
                          ),
                          title: Text(
                              '${tx.quantity.toStringAsFixed(2)} chỉ vàng'),
                          subtitle: Text(
                              '${formatPrice(tx.price)} đ/chỉ - ${tx.date.toString().split(' ')[0]}'),
                          trailing: Text(formatPrice(tx.totalCost),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<PortfolioProvider>(
        builder: (context, portfolio, _) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add_transaction');
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }
}
