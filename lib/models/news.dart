class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String source;
  final DateTime publishedAt;
  final String imageUrl;
  final NewsType type;
  final int impact;
  final int readCount;
  final String link;

  NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.publishedAt,
    required this.imageUrl,
    required this.type,
    required this.impact,
    this.readCount = 0,
    this.link = '',
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] ?? '',
      summary: json['description'] ?? json['summary'] ?? '',
      source: json['source'] ?? 'Unknown',
      publishedAt: json['pubDate'] != null
          ? DateTime.parse(json['pubDate'])
          : DateTime.now(),
      imageUrl: json['imageUrl'] ??
          'https://picsum.photos/200/150?random=${DateTime.now().millisecondsSinceEpoch}',
      type: _parseNewsType(json['type'] ?? 'all'),
      impact: json['impact'] ?? 3,
      readCount: json['readCount'] ?? 0,
      link: json['link'] ?? '',
    );
  }

  static NewsType _parseNewsType(String type) {
    switch (type.toLowerCase()) {
      case 'gold':
        return NewsType.gold;
      case 'economy':
        return NewsType.economy;
      case 'world':
        return NewsType.world;
      case 'analysis':
        return NewsType.analysis;
      default:
        return NewsType.all;
    }
  }
}

enum NewsType {
  all,
  gold,
  economy,
  world,
  analysis,
}

extension NewsTypeExtension on NewsType {
  String get displayName {
    switch (this) {
      case NewsType.all:
        return 'Tất cả';
      case NewsType.gold:
        return 'Giá vàng';
      case NewsType.economy:
        return 'Kinh tế';
      case NewsType.world:
        return 'Thế giới';
      case NewsType.analysis:
        return 'Phân tích';
    }
  }

  String get icon {
    switch (this) {
      case NewsType.all:
        return '🔥';
      case NewsType.gold:
        return '💰';
      case NewsType.economy:
        return '📊';
      case NewsType.world:
        return '🌍';
      case NewsType.analysis:
        return '📈';
    }
  }
}
