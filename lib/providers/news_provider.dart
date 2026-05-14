import 'package:flutter/material.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _allNews = [];
  List<Map<String, dynamic>> _goldNews = [];
  List<Map<String, dynamic>> _economyNews = [];
  List<Map<String, dynamic>> _worldNews = [];
  List<Map<String, dynamic>> _analysisNews = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get allNews => _allNews;
  List<Map<String, dynamic>> get goldNews => _goldNews;
  List<Map<String, dynamic>> get economyNews => _economyNews;
  List<Map<String, dynamic>> get worldNews => _worldNews;
  List<Map<String, dynamic>> get analysisNews => _analysisNews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  NewsProvider() {
    fetchAllNews();
  }

  Future<void> fetchAllNews() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final allArticles = await NewsService.fetchAllNews();

      _allNews = allArticles;
      _goldNews = allArticles.where((a) => a['category'] == 'gold').toList();
      _economyNews =
          allArticles.where((a) => a['category'] == 'economy').toList();
      _worldNews = allArticles.where((a) => a['category'] == 'world').toList();
      _analysisNews =
          allArticles.where((a) => a['category'] == 'analysis').toList();

      print('✅ Tổng số tin: ${_allNews.length}');
      print('💰 Tin giá vàng: ${_goldNews.length}');
      print('📊 Tin kinh tế: ${_economyNews.length}');

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải tin tức. Vui lòng kiểm tra kết nối.';
      print('Error fetching news: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchNews(String keyword) async {
    if (keyword.isEmpty) {
      await fetchAllNews();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _allNews = await NewsService.searchNews(keyword);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshNews() async {
    await fetchAllNews();
  }
}
