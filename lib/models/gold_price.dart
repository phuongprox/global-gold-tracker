class GoldPrice {
  final String name;
  final int buyPrice;
  final int sellPrice;
  final bool isFavorite;
  final bool isWorldPrice;

  GoldPrice({
    required this.name,
    required this.buyPrice,
    required this.sellPrice,
    this.isFavorite = false,
    this.isWorldPrice = false,
  });
}
