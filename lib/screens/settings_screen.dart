import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  bool _isPinEnabled = false;
  double _fontSize = 1.0;
  String _appVersion = '1.0.0';
  String _selectedLanguage = 'Tiếng Việt';
  bool _isNotificationEnabled = true;
  bool _isAutoRefreshEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getAppVersion();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _isPinEnabled = prefs.getBool('pinEnabled') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 1.0;
      _selectedLanguage = prefs.getString('language') ?? 'Tiếng Việt';
      _isNotificationEnabled = prefs.getBool('notificationEnabled') ?? true;
      _isAutoRefreshEnabled = prefs.getBool('autoRefreshEnabled') ?? true;
    });
  }

  Future<void> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kích thước chữ'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: _fontSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: '${(_fontSize * 100).toInt()}%',
                  onChanged: (value) {
                    setStateDialog(() {
                      _fontSize = value;
                    });
                    setState(() {
                      _fontSize = value;
                    });
                    _saveSetting('fontSize', value);
                  },
                ),
                Text(
                  'Mẫu chữ: Đây là văn bản thử nghiệm',
                  style: TextStyle(fontSize: 14 * _fontSize),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['Tiếng Việt', 'English', '中文'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSetting('language', value!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã chuyển sang $value')),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thiết lập mã PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập mã PIN 4 số:'),
            const SizedBox(height: 16),
            TextField(
              obscureText: true,
              maxLength: 4,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '****',
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  _saveSetting('pinCode', value);
                  setState(() {
                    _isPinEnabled = true;
                  });
                  _saveSetting('pinEnabled', true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cài đặt mã PIN')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPinDisableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa mã PIN'),
        content: const Text('Bạn có chắc muốn xóa mã PIN?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('pinCode');
              setState(() {
                _isPinEnabled = false;
              });
              _saveSetting('pinEnabled', false);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa mã PIN')),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở liên kết')),
      );
    }
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gửi góp ý'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Nhập ý kiến của bạn...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Gửi feedback lên server
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cảm ơn bạn đã góp ý!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: ListView(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                      const Icon(Icons.settings, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cài đặt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tùy chỉnh ứng dụng theo cách của bạn',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Trạng thái tài khoản
          _buildSection(
            title: 'TRẠNG THÁI TÀI KHOẢN',
            icon: Icons.account_circle,
            children: [
              _buildProfileItem(),
            ],
          ),

          // Giao diện
          _buildSection(
            title: 'GIAO DIỆN',
            icon: Icons.palette,
            children: [
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Chế độ tối',
                subtitle: 'Chuyển đổi giao diện sáng/tối',
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() => _isDarkMode = value);
                  _saveSetting('darkMode', value);
                  // TODO: Implement theme change
                },
              ),
              _buildSliderTile(
                icon: Icons.text_fields,
                title: 'Kích thước chữ',
                subtitle: 'Điều chỉnh tỉ lệ phóng to/thu nhỏ',
                value: _fontSize,
                onTap: _showFontSizeDialog,
              ),
              _buildButtonTile(
                icon: Icons.language,
                title: 'Ngôn ngữ',
                subtitle: _selectedLanguage,
                onTap: _showLanguageDialog,
              ),
            ],
          ),

          // Bảo mật
          _buildSection(
            title: 'BẢO MẬT',
            icon: Icons.security,
            children: [
              _buildButtonTile(
                icon: Icons.pin,
                title: 'Mã PIN',
                subtitle: _isPinEnabled ? 'Đã bật' : 'Chưa cài đặt',
                onTap: _isPinEnabled ? _showPinDisableDialog : _showPinDialog,
              ),
            ],
          ),

          // Cài đặt dữ liệu
          _buildSection(
            title: 'DỮ LIỆU',
            icon: Icons.data_usage,
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Thông báo',
                subtitle: 'Nhận thông báo khi giá đạt ngưỡng',
                value: _isNotificationEnabled,
                onChanged: (value) {
                  setState(() => _isNotificationEnabled = value);
                  _saveSetting('notificationEnabled', value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.refresh,
                title: 'Tự động làm mới',
                subtitle: 'Tự động cập nhật giá vàng',
                value: _isAutoRefreshEnabled,
                onChanged: (value) {
                  setState(() => _isAutoRefreshEnabled = value);
                  _saveSetting('autoRefreshEnabled', value);
                },
              ),
              _buildButtonTile(
                icon: Icons.delete_sweep,
                title: 'Xóa dữ liệu',
                subtitle: 'Xóa tất cả giao dịch và cài đặt',
                onTap: _showClearDataDialog,
                color: Colors.red,
              ),
            ],
          ),

          // Thông tin & Hỗ trợ
          _buildSection(
            title: 'THÔNG TIN & HỖ TRỢ',
            icon: Icons.info,
            children: [
              _buildButtonTile(
                icon: Icons.privacy_tip,
                title: 'Chính sách bảo mật',
                subtitle: 'Tuyệt đối tôn trọng thông tin người dùng',
                onTap: () => _launchURL('https://example.com/privacy'),
              ),
              _buildButtonTile(
                icon: Icons.description,
                title: 'Điều khoản sử dụng',
                subtitle: 'Quy định và điều khoản',
                onTap: () => _launchURL('https://example.com/terms'),
              ),
              _buildButtonTile(
                icon: Icons.support_agent,
                title: 'Liên hệ hỗ trợ',
                subtitle: 'Hỗ trợ kỹ thuật & hợp tác',
                onTap: () => _launchURL('mailto:support@tichchi.com'),
              ),
              _buildButtonTile(
                icon: Icons.feedback,
                title: 'Góp ý & Báo lỗi',
                subtitle: 'Đóng góp ý kiến để cải thiện',
                onTap: _showFeedbackDialog,
              ),
            ],
          ),

          // Chia sẻ & Đánh giá
          _buildSection(
            title: 'KẾT NỐI',
            icon: Icons.share,
            children: [
              _buildButtonTile(
                icon: Icons.share,
                title: 'Chia sẻ ứng dụng',
                subtitle: 'Giới thiệu Tích Chỉ đến bạn bè',
                onTap: () {
                  // TODO: Implement share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tính năng đang phát triển')),
                  );
                },
              ),
              _buildButtonTile(
                icon: Icons.star,
                title: 'Đánh giá ứng dụng',
                subtitle: 'Đánh giá 5 sao để ủng hộ chúng tôi',
                onTap: () => _launchURL('https://example.com/review'),
              ),
            ],
          ),

          // Phiên bản
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phiên bản ứng dụng',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _appVersion,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Build number',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '1.0.0+1',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Đã có',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Đăng nhập Google',
                  style: TextStyle(fontSize: 13),
                ),
                Text(
                  'demo@gmail.com',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement logout
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      secondary: Icon(icon, color: Colors.amber),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.amber,
    );
  }

  Widget _buildButtonTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: color ?? Colors.amber),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Icon(icon, color: Colors.amber),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Text('${(value * 100).toInt()}%'),
      onTap: onTap,
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa dữ liệu'),
        content: const Text(
            'Bạn có chắc muốn xóa tất cả giao dịch và cài đặt? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              // TODO: Clear all data
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              setState(() {
                _isDarkMode = false;
                _isPinEnabled = false;
                _fontSize = 1.0;
                _isNotificationEnabled = true;
                _isAutoRefreshEnabled = true;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa dữ liệu thành công')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
