import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/portfolio_provider.dart';
import '../models/transaction.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'BUY';
  double _quantity = 1.0;
  int _price = 17240000;
  DateTime _date = DateTime.now();

  String formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm tích lũy'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'BUY',
                      label: Text('Mua vàng'),
                      icon: Icon(Icons.shopping_cart)),
                  ButtonSegment(
                      value: 'SELL',
                      label: Text('Bán vàng'),
                      icon: Icon(Icons.monetization_on)),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Số lượng (chỉ)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                initialValue: _quantity.toString(),
                onChanged: (value) => _quantity = double.tryParse(value) ?? 0,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Vui lòng nhập số hợp lệ'
                        : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                    labelText: 'Giá mua/bán (đ/chỉ)',
                    border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                initialValue: _price.toString(),
                onChanged: (value) =>
                    _price = int.tryParse(value.replaceAll('.', '')) ?? 0,
                validator: (value) => value == null ||
                        int.tryParse(value.replaceAll('.', '')) == null
                    ? 'Vui lòng nhập số hợp lệ'
                    : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Ngày giao dịch'),
                subtitle: Text(_date.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final transaction = Transaction(
                        date: _date,
                        quantity: _type == 'SELL' ? -_quantity : _quantity,
                        price: _price,
                        type: _type,
                      );
                      Provider.of<PortfolioProvider>(context, listen: false)
                          .addTransaction(transaction);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Đã ${_type == 'BUY' ? 'mua' : 'bán'} ${_quantity} chỉ vàng')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text(_type == 'BUY' ? 'Xác nhận mua' : 'Xác nhận bán'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
