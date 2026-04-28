import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketChannel? _channel;
  final StreamController<Map<String, dynamic>> _priceController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get priceStream => _priceController.stream;

  WebSocketService._();

  // Kết nối WebSocket (ví dụ với Binance)
  void connect() {
    // WebSocket URL cho giá vàng (ví dụ: Binance XAU/USDT)
    const wsUrl = 'wss://stream.binance.com:9443/ws/xauusdt@trade';

    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel!.stream.listen((message) {
      final data = _parseWebSocketMessage(message);
      _priceController.add(data);
    }, onError: (error) {
      print('WebSocket error: $error');
      _reconnect();
    }, onDone: () {
      print('WebSocket disconnected');
      _reconnect();
    });
  }

  Map<String, dynamic> _parseWebSocketMessage(dynamic message) {
    // Parse message từ Binance hoặc provider khác
    // TODO: Parse theo format cụ thể của WebSocket provider
    return {
      'price': 2350.50,
      'change': 0.07,
      'timestamp': DateTime.now(),
    };
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      connect();
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _priceController.close();
  }
}
