import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.2.4:3000/api';

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/transactions'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) {
          return {
            'id': e['id'],
            'quantity': e['quantity'] is String
                ? double.parse(e['quantity'])
                : e['quantity'],
            'price': e['price'] is String ? int.parse(e['price']) : e['price'],
            'type': e['type'],
            'date': e['date'],
          };
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Lỗi getTransactions: $e');
      return [];
    }
  }

  static Future<bool> addTransaction({
    required double quantity,
    required int price,
    required String type,
    required DateTime date,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'quantity': quantity,
          'price': price,
          'type': type,
          'date': date.toIso8601String(),
        }),
      );

      print('Trạng thái thêm giao dịch: ${response.statusCode}');
      print('Response: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi addTransaction: $e');
      return false;
    }
  }

  static Future<bool> deleteTransaction(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/transactions/$id'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi deleteTransaction: $e');
      return false;
    }
  }
}
