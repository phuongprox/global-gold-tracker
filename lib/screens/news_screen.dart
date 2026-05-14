import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/news_provider.dart';
import '../widgets/news_card.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm tin tức...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  _performSearch(value);
                },
              )
            : const Text(
                'Tin tức vàng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        backgroundColor: Colors.amber,
        elevation: 0,
        bottom: !_isSearching
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(text: '🔥 Tất cả'),
                  Tab(text: '💰 Giá vàng'),
                  Tab(text: '📊 Kinh tế'),
                  Tab(text: '🌍 Thế giới'),
                ],
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  Provider.of<NewsProvider>(context, listen: false)
                      .refreshNews();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<NewsProvider>(context, listen: false).refreshNews();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang cập nhật tin tức...')),
                );
              },
            ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allNews.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 16),
                  Text('Đang tải tin tức...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.allNews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshNews(),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (_isSearching) {
            return _buildNewsList(provider.allNews);
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildNewsList(provider.allNews),
              _buildNewsList(provider.goldNews),
              _buildNewsList(provider.economyNews),
              _buildNewsList(provider.worldNews),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNewsList(List<Map<String, dynamic>> news) {
    if (news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có tin tức mới',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Kéo xuống để làm mới',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<NewsProvider>(context, listen: false).refreshNews();
      },
      color: Colors.amber,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: news.length,
        itemBuilder: (context, index) {
          final item = news[index];
          return NewsCard(
            news: item,
            onTap: () => _openNewsDetail(item),
          );
        },
      ),
    );
  }

  void _openNewsDetail(Map<String, dynamic> news) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.all(12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình ảnh
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: news['imageUrl'] != null &&
                                  news['imageUrl'].isNotEmpty
                              ? Image.network(
                                  news['imageUrl'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey[400],
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.newspaper,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Source và thời gian
                      Row(
                        children: [
                          Text(
                            news['source'] ?? 'Unknown',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatDate(news['pubDate']),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        news['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Content
                      Text(
                        news['content'] ?? news['description'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Nút đọc thêm
                      if (news['link'] != null && news['link'].isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _launchURL(news['link']),
                            icon: const Icon(Icons.open_in_browser),
                            label: const Text('Đọc bài viết gốc'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performSearch(String keyword) {
    if (keyword.isNotEmpty) {
      Provider.of<NewsProvider>(context, listen: false).searchNews(keyword);
    }
    setState(() {
      _isSearching = false;
    });
    _searchController.clear();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở link')),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day}/${date.month}/${date.year}';
  }
}
