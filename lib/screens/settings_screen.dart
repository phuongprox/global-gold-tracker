import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Trạng thái tạo số vàng
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TRANG THÁI TẠO SỐ VÀNG',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 16),
                    SizedBox(width: 8),
                    Text('Đã có'),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Đăng nhập Google'),
                const Text('namphuong.844220@gmail.com',
                    style: TextStyle(color: Colors.blue)),
                TextButton(
                    onPressed: () {},
                    child: const Text('Đăng xuất',
                        style: TextStyle(color: Colors.red))),
              ],
            ),
          ),

          // Cấu hình
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSettingRow(
                    'Kích thước chữ', 'Điều chỉnh tỉ lệ phóng to/thu nhỏ chữ'),
                const Divider(),
                _buildSettingRow(
                    'Thiết lập mã PIN', 'Bảo vệ ứng dụng bằng mã PIN'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Thông tin & hỗ trợ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildSettingRow('Cam Kết Bảo Mật & Quyền Riêng Tư',
                    'Tuyệt đối tôn trọng thông tin người dùng!'),
                const Divider(),
                _buildSettingRow('Điều khoản sử dụng', ''),
                const Divider(),
                _buildSettingRow(
                    'Liên hệ nhà phát triển', 'Hỗ trợ kỹ thuật & hợp tác'),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            child: Text('Phiên bản ứng dụng: production.env.production 1.0.0',
                style: TextStyle(color: Colors.grey[600])),
          ),

          const SizedBox(height: 16),

          // Đánh giá và chia sẻ
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildActionRow(Icons.link, 'Lời tắt'),
                const Divider(),
                _buildActionRow(Icons.share, 'Chia sẻ'),
                const Divider(),
                _buildActionRow(Icons.qr_code, 'Zalo Mini App'),
                const Divider(),
                _buildActionRow(Icons.error_outline, 'Báo lỗi - Góp ý'),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSettingRow(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildActionRow(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
