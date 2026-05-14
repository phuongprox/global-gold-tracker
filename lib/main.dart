import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/market_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/news_provider.dart';
import 'screens/main_screen.dart';
import 'screens/add_transaction_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => NewsProvider()),
      ],
      child: MaterialApp(
        title: 'Tích Chỉ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          fontFamily: 'Roboto',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          useMaterial3: true,
        ),
        home: const MainScreen(),
        routes: {
          '/add_transaction': (context) => const AddTransactionScreen(),
        },
      ),
    );
  }
}
