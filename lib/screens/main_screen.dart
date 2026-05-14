import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'gold_screen.dart';
import 'portfolio_screen.dart';
import 'news_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const GoldScreen(),
    const PortfolioScreen(),
    const NewsScreen(),
    const SettingsScreen(),
  ];

  final List<String> _titles = [
    'Trang chủ',
    'Giá vàng',
    'Sổ vàng',
    'Tin tức',
    'Cài đặt',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: 'Giá vàng'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'Sổ vàng'),
          BottomNavigationBarItem(
              icon: Icon(Icons.newspaper), label: 'Tin tức'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
        ],
      ),
    );
  }
}
