import 'package:flutter/material.dart';
import '../models/news.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsModel> _allNews = [];
  List<NewsModel> _goldNews = [];
  List<NewsModel> _economyNews = [];
  List<NewsModel> _worldNews = [];
  List<NewsModel> _analysisNews = [];

  bool _isLoading = false;
  String? _errorMessage;
  TabController? _tabController;

  // Getters
  List<NewsModel> get allNews => _allNews;
  List<NewsModel> get goldNews => _goldNews;
  List<NewsModel> get economyNews => _economyNews;
  List<NewsModel> get worldNews => _worldNews;
  List<NewsModel> get analysisNews => _analysisNews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setTabController(TabController controller) {
    _tabController = controller;
  }

  NewsProvider() {
    fetchNews();
  }

  // Tải tin tức từ RSS feeds
  Future<void> fetchNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final rawNews = await _newsService.fetchGoldNews();

      // Chuyển đổi từ Map sang NewsModel
      _allNews = rawNews.map((item) => NewsModel.fromJson(item)).toList();

      // Phân loại tin tức
      _filterNews();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải tin tức. Vui lòng kiểm tra kết nối.';
      print('Error fetching news: $e');

      // Dùng mock data nếu lỗi
      _loadMockNews();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _filterNews() {
    _goldNews = _allNews.where((n) => n.type == NewsType.gold).toList();
    _economyNews = _allNews.where((n) => n.type == NewsType.economy).toList();
    _worldNews = _allNews.where((n) => n.type == NewsType.world).toList();
    _analysisNews = _allNews.where((n) => n.type == NewsType.analysis).toList();
  }

  void _loadMockNews() {
    _allNews = [
      NewsModel(
        id: '1',
        title: 'Giá vàng hôm nay: Dự báo xu hướng tăng trong tuần tới',
        summary:
            'Các chuyên gia nhận định giá vàng có thể tiếp tục đà tăng do nhu cầu trú ẩn an toàn.',
        source: 'VnEconomy',
        publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
        imageUrl: 'https://picsum.photos/200/150?random=1',
        type: NewsType.gold,
        impact: 4,
        readCount: 1234,
      ),
      NewsModel(
        id: '2',
        title: 'Fed giữ nguyên lãi suất, vàng tăng giá mạnh',
        summary:
            'Quyết định của Fed về việc duy trì lãi suất đã hỗ trợ đà tăng của giá vàng.',
        source: 'Reuters',
        publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
        imageUrl: 'https://picsum.photos/200/150?random=2',
        type: NewsType.economy,
        impact: 5,
        readCount: 3456,
      ),
      NewsModel(
        id: '3',
        title: 'Phân tích kỹ thuật: Vàng đang trong xu hướng tăng trung hạn',
        summary: 'Các chỉ báo kỹ thuật cho thấy vàng có thể đạt mức cao mới.',
        source: 'GoldAnalysis',
        publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
        imageUrl: 'https://picsum.photos/200/150?random=3',
        type: NewsType.analysis,
        impact: 3,
        readCount: 2345,
      ),
      NewsModel(
        id: '4',
        title: 'Trung Quốc tăng cường dự trữ vàng',
        summary: 'Ngân hàng Trung ương Trung Quốc tiếp tục mua vàng.',
        source: 'Bloomberg',
        publishedAt: DateTime.now().subtract(const Duration(hours: 12)),
        imageUrl: 'https://picsum.photos/200/150?random=4',
        type: NewsType.world,
        impact: 4,
        readCount: 4567,
      ),
    ];
    _filterNews();
  }

  Future<void> refreshNews() async {
    await fetchNews();
  }

  Future<void> searchNews(String keyword) async {
    if (keyword.isEmpty) {
      await fetchNews();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final filtered = _allNews
        .where((news) =>
            news.title.toLowerCase().contains(keyword.toLowerCase()) ||
            news.summary.toLowerCase().contains(keyword.toLowerCase()))
        .toList();

    _allNews = filtered;
    _filterNews();
    _isLoading = false;
    notifyListeners();
  }
}
