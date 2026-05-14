import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  // Danh sách RSS feeds chuyển qua RSS2JSON API
  static final List<Map<String, String>> _rssFeeds = [
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://vnexpress.net/rss/kinh-doanh.rss',
      'name': 'VnExpress - Kinh doanh',
      'category': 'economy'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://vneconomy.vn/feeds/tai-chinh.rss',
      'name': 'VnEconomy - Tài chính',
      'category': 'economy'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://vneconomy.vn/feeds/thi-truong.rss',
      'name': 'VnEconomy - Thị trường',
      'category': 'economy'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://cafef.vn/du-lieu/tai-chinh.chn',
      'name': 'CafeF - Tài chính',
      'category': 'economy'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://cafef.vn/du-lieu/thi-truong-chung-khoan.chn',
      'name': 'CafeF - Thị trường',
      'category': 'economy'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://www.kitco.com/rss/',
      'name': 'Kitco - Gold News',
      'category': 'gold'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://www.reuters.com/markets/commodities/gold/',
      'name': 'Reuters - Gold',
      'category': 'gold'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://www.bloomberg.com/feeds/markets.rss',
      'name': 'Bloomberg - Markets',
      'category': 'world'
    },
    {
      'url':
          'https://api.rss2json.com/v1/api.json?rss_url=https://www.ft.com/markets?format=rss',
      'name': 'Financial Times - Markets',
      'category': 'world'
    },
  ];

  /// Lấy tin tức từ tất cả RSS feeds qua RSS2JSON API
  static Future<List<Map<String, dynamic>>> fetchAllNews() async {
    List<Map<String, dynamic>> allArticles = [];

    for (var feed in _rssFeeds) {
      try {
        final articles =
            await _fetchRSSFeed(feed['url']!, feed['name']!, feed['category']!);
        allArticles.addAll(articles);
        print('✅ Đã lấy ${articles.length} bài từ ${feed['name']}');
      } catch (e) {
        print('❌ Lỗi khi lấy feed ${feed['name']}: $e');
      }
    }

    // Sắp xếp theo ngày mới nhất
    allArticles.sort((a, b) => b['pubDate'].compareTo(a['pubDate']));

    print('✅ Tổng số tin: ${allArticles.length}');
    return allArticles;
  }

  /// Lấy tin tức theo category
  static Future<List<Map<String, dynamic>>> fetchNewsByCategory(
      String category) async {
    final allNews = await fetchAllNews();
    if (category == 'all') return allNews;
    return allNews.where((news) => news['category'] == category).toList();
  }

  /// Parse RSS feed qua RSS2JSON API
  static Future<List<Map<String, dynamic>>> _fetchRSSFeed(
    String apiUrl,
    String sourceName,
    String category,
  ) async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra status
        if (data['status'] != 'ok') {
          print('⚠️ API trả về lỗi cho $sourceName: ${data['message']}');
          return [];
        }

        final items = data['items'] as List? ?? [];
        final List<Map<String, dynamic>> articles = [];

        for (var item in items) {
          // Lấy hình ảnh từ enclosure hoặc thumbnail
          String imageUrl = '';
          if (item['enclosure'] != null && item['enclosure']['link'] != null) {
            imageUrl = item['enclosure']['link'];
          } else if (item['thumbnail'] != null) {
            imageUrl = item['thumbnail'];
          } else {
            // Tìm ảnh trong description
            imageUrl = _extractImageFromHtml(item['description'] ?? '');
          }

          // Nếu không có ảnh, dùng ảnh mặc định
          if (imageUrl.isEmpty) {
            imageUrl =
                'https://picsum.photos/200/150?random=${DateTime.now().millisecondsSinceEpoch}';
          }

          // Parse ngày tháng
          DateTime pubDate;
          try {
            pubDate = DateTime.parse(
                item['pubDate'] ?? DateTime.now().toIso8601String());
          } catch (e) {
            pubDate = DateTime.now();
          }

          articles.add({
            'title': item['title'] ?? '',
            'description': _stripHtml(item['description'] ?? ''),
            'content': _stripHtml(item['content'] ?? item['description'] ?? ''),
            'link': item['link'] ?? '',
            'pubDate': pubDate,
            'source': sourceName,
            'category': category,
            'imageUrl': imageUrl,
            'author': item['author'] ?? '',
          });
        }

        return articles;
      }

      return [];
    } catch (e) {
      print('Lỗi fetch RSS feed $sourceName: $e');
      return [];
    }
  }

  /// Trích xuất URL hình ảnh từ HTML
  static String _extractImageFromHtml(String html) {
    try {
      // Tìm src="..."
      final startIndex = html.indexOf('src="');
      if (startIndex != -1) {
        final endIndex = html.indexOf('"', startIndex + 5);
        if (endIndex != -1) {
          return html.substring(startIndex + 5, endIndex);
        }
      }

      // Tìm src='...'
      final startIndex2 = html.indexOf("src='");
      if (startIndex2 != -1) {
        final endIndex2 = html.indexOf("'", startIndex2 + 5);
        if (endIndex2 != -1) {
          return html.substring(startIndex2 + 5, endIndex2);
        }
      }
    } catch (e) {
      print('Lỗi extract image: $e');
    }

    return '';
  }

  /// Loại bỏ HTML tags
  static String _stripHtml(String html) {
    final regex = RegExp(r'<[^>]*>');
    return html.replaceAll(regex, '').trim();
  }

  /// Tìm kiếm tin tức
  static Future<List<Map<String, dynamic>>> searchNews(String keyword) async {
    final allNews = await fetchAllNews();
    final lowerKeyword = keyword.toLowerCase();

    return allNews.where((news) {
      return news['title'].toLowerCase().contains(lowerKeyword) ||
          news['description'].toLowerCase().contains(lowerKeyword);
    }).toList();
  }

  /// Lấy tin nổi bật (5 bài mới nhất)
  static Future<List<Map<String, dynamic>>> getFeaturedNews() async {
    final allNews = await fetchAllNews();
    return allNews.take(5).toList();
  }

  /// Lấy tin theo nguồn
  static Future<List<Map<String, dynamic>>> getNewsBySource(
      String sourceName) async {
    final allNews = await fetchAllNews();
    return allNews.where((news) => news['source'] == sourceName).toList();
  }
}
