import 'package:flutter/material.dart';

class PriceCard extends StatelessWidget {
  final String name;
  final int buyPrice;
  final int sellPrice;
  final bool isFavorite;
  final bool isWorldPrice;
  final VoidCallback? onFavoriteTap;

  const PriceCard({
    Key? key,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    this.isFavorite = false,
    this.isWorldPrice = false,
    this.onFavoriteTap,
  }) : super(key: key);

  String formatPrice(int price) {
    // Nếu là giá thế giới (USD), format khác
    if (isWorldPrice && name.contains('XAU/USD')) {
      return '\$${price.toStringAsFixed(2)}';
    }
    return price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isWorldPrice ? 2 : 0,
      child: Container(
        decoration: isWorldPrice
            ? BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon cho giá thế giới
              if (isWorldPrice)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child:
                      const Icon(Icons.public, color: Colors.amber, size: 20),
                ),
              Expanded(
                flex: 3,
                child: Text(
                  name,
                  style: TextStyle(
                    fontWeight:
                        isWorldPrice ? FontWeight.bold : FontWeight.normal,
                    color: isWorldPrice ? Colors.amber.shade800 : null,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatPrice(buyPrice),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isWorldPrice ? Colors.amber : Colors.green,
                    fontWeight:
                        isWorldPrice ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  formatPrice(sellPrice),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isWorldPrice ? Colors.amber : Colors.red,
                    fontWeight:
                        isWorldPrice ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onFavoriteTap,
                child: Icon(
                  isFavorite ? Icons.star : Icons.star_border,
                  color: isFavorite ? Colors.amber : Colors.grey,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
