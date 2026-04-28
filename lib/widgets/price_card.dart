import 'package:flutter/material.dart';

class PriceCard extends StatelessWidget {
  final String name;
  final int buyPrice;
  final int sellPrice;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const PriceCard({
    Key? key,
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    this.isFavorite = false,
    this.onFavoriteTap,
  }) : super(key: key);

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(name,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
            Expanded(
              flex: 2,
              child: Text(formatPrice(buyPrice),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.green)),
            ),
            Expanded(
              flex: 2,
              child: Text(formatPrice(sellPrice),
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.red)),
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
    );
  }
}
