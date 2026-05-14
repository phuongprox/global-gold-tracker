import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../models/transaction.dart';
import 'add_transaction_screen.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Sổ vàng',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PortfolioProvider>(context, listen: false)
                  .refreshData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang cập nhật...')),
              );
            },
          ),
        ],
      ),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolio, _) {
          if (portfolio.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 16),
                  Text('Đang tải dữ liệu...'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await portfolio.refreshData();
            },
            color: Colors.amber,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Thống kê
                  Container(
                    padding: const EdgeInsets.all(16),
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
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  const Text('Giá trị hiện tại',
                                      style: TextStyle(color: Colors.grey)),
                                  Text(
                                      '${formatPrice(portfolio.currentValue)} đ',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
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
                            const Text('Lãi/Lỗ',
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

                  // Lịch sử giao dịch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lịch sử tích lũy',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Chọn bộ lọc'),
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddTransactionScreen()),
                              );
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
                        final isBuy = tx.type == 'BUY';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  isBuy ? Colors.green : Colors.red,
                              child: Icon(
                                  isBuy
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color: Colors.white),
                            ),
                            title: Text(
                              '${tx.quantity.abs().toStringAsFixed(2)} chỉ vàng',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                '${formatPrice(tx.price)} đ/chỉ - ${formatDate(tx.date)}'),
                            trailing: Text(
                              formatPrice(tx.totalCost),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isBuy ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddTransactionScreen()),
          ).then((_) {
            // Refresh khi quay lại
            Provider.of<PortfolioProvider>(context, listen: false)
                .refreshData();
          });
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }
}
