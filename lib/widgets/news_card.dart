import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewsCard extends StatelessWidget {
  final Map<String, dynamic> news;
  final VoidCallback? onTap;

  const NewsCard({
    Key? key,
    required this.news,
    this.onTap,
  }) : super(key: key);

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case 'gold':
        return '💰';
      case 'economy':
        return '📊';
      case 'world':
        return '🌍';
      case 'analysis':
        return '📈';
      default:
        return '📰';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'gold':
        return Colors.amber;
      case 'economy':
        return Colors.blue;
      case 'world':
        return Colors.green;
      case 'analysis':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'gold':
        return 'Giá vàng';
      case 'economy':
        return 'Kinh tế';
      case 'world':
        return 'Thế giới';
      case 'analysis':
        return 'Phân tích';
      default:
        return 'Tin tức';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: news['imageUrl'] != null && news['imageUrl'].isNotEmpty
                      ? Image.network(
                          news['imageUrl'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.grey[400],
                            );
                          },
                        )
                      : Icon(
                          Icons.newspaper,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                ),
              ),
              const SizedBox(width: 12),
              // Nội dung
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge và thời gian
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(news['category'])
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getCategoryIcon(news['category']),
                                style: const TextStyle(fontSize: 10),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _getCategoryName(news['category']),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getCategoryColor(news['category']),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            news['source'] ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _getTimeAgo(news['pubDate']),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      news['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Description
                    Text(
                      news['description'] ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
