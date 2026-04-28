import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsService {
  // Danh sách RSS feed về vàng và tài chính
  final List<String> _goldRssFeeds = [
    'https://vnexpress.net/rss/kinh-doanh.rss',
    'https://vneconomy.vn/feeds/tai-chinh.rss',
    'https://cafef.vn/du-lieu/gia-vang.chn',
  ];

  // Lấy tin tức từ RSS feeds
  Future<List<Map<String, dynamic>>> fetchGoldNews() async {
    List<Map<String, dynamic>> allNews = [];

    // Tạm thời trả về mock data
    // TODO: Implement RSS parsing thực tế
    allNews = _getMockNews();

    return allNews;
  }

  List<Map<String, dynamic>> _getMockNews() {
    return [
      {
        'id': '1',
        'title': 'Giá vàng hôm nay: Dự báo xu hướng tăng trong tuần tới',
        'description':
            'Các chuyên gia nhận định giá vàng có thể tiếp tục đà tăng.',
        'source': 'VnEconomy',
        'pubDate':
            DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        'type': 'gold',
        'impact': 4,
        'readCount': 1234,
      },
      {
        'id': '2',
        'title': 'Fed giữ nguyên lãi suất, vàng tăng giá mạnh',
        'description':
            'Quyết định của Fed về việc duy trì lãi suất đã hỗ trợ đà tăng.',
        'source': 'Reuters',
        'pubDate':
            DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
        'type': 'economy',
        'impact': 5,
        'readCount': 3456,
      },
      {
        'id': '3',
        'title': 'Phân tích kỹ thuật: Vàng đang trong xu hướng tăng trung hạn',
        'description':
            'Các chỉ báo kỹ thuật cho thấy vàng có thể đạt mức cao mới.',
        'source': 'GoldAnalysis',
        'pubDate':
            DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
        'type': 'analysis',
        'impact': 3,
        'readCount': 2345,
      },
    ];
  }
}
