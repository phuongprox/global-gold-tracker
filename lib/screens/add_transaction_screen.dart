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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm tích lũy',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _type == 'BUY'
                                ? Icons.shopping_cart
                                : Icons.monetization_on,
                            color: Colors.amber.shade800,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Giao dịch mới',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                _type == 'BUY'
                                    ? 'Thêm vàng vào danh mục'
                                    : 'Bán vàng khỏi danh mục',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Loại giao dịch',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'BUY',
                            label: Text('🟢 Mua vàng'),
                            icon: Icon(Icons.shopping_cart)),
                        ButtonSegment(
                            value: 'SELL',
                            label: Text('🔴 Bán vàng'),
                            icon: Icon(Icons.monetization_on)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _type = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return _type == 'BUY' ? Colors.green : Colors.red;
                          }
                          return Colors.white;
                        }),
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          return Colors.grey.shade700;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Số lượng',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: TextFormField(
                      initialValue: _quantity.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số lượng vàng',
                        hintText: 'Nhập số lượng (chỉ)',
                        prefixIcon:
                            Icon(Icons.workspace_premium, color: Colors.amber),
                        suffixText: 'chỉ',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        _quantity = double.tryParse(value) ?? 0;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Vui lòng nhập số lượng';
                        if (double.tryParse(value) == null)
                          return 'Vui lòng nhập số hợp lệ';
                        if (double.parse(value) <= 0)
                          return 'Số lượng phải lớn hơn 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Giá giao dịch',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: TextFormField(
                      initialValue: _price.toString(),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Giá mua/bán',
                        hintText: 'Nhập giá (VNĐ/chỉ)',
                        prefixIcon:
                            Icon(Icons.attach_money, color: Colors.amber),
                        prefixText: '₫ ',
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: (value) {
                        _price = int.tryParse(value.replaceAll('.', '')) ?? 0;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Vui lòng nhập giá';
                        if (int.tryParse(value.replaceAll('.', '')) == null)
                          return 'Vui lòng nhập số hợp lệ';
                        if (int.parse(value.replaceAll('.', '')) <= 0)
                          return 'Giá phải lớn hơn 0';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Ngày giao dịch',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.calendar_today,
                            color: Colors.amber),
                      ),
                      title: const Text('Chọn ngày'),
                      subtitle: Text(
                          '${_date.day}/${_date.month}/${_date.year}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                    primary: Colors.amber,
                                    onPrimary: Colors.white),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setState(() {
                            _date = picked;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _type == 'BUY' ? Colors.green : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_type == 'BUY'
                                    ? Icons.check_circle
                                    : Icons.sell),
                                const SizedBox(width: 12),
                                Text(
                                    _type == 'BUY'
                                        ? 'Xác nhận mua vàng'
                                        : 'Xác nhận bán vàng',
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final transaction = Transaction(
          date: _date,
          quantity: _type == 'SELL' ? -_quantity : _quantity,
          price: _price,
          type: _type,
        );

        await Provider.of<PortfolioProvider>(context, listen: false)
            .addTransaction(transaction);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_type == 'BUY'
                  ? '✅ Đã mua thành công ${_quantity} chỉ vàng'
                  : '✅ Đã bán thành công ${_quantity} chỉ vàng'),
              backgroundColor: _type == 'BUY' ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('❌ Lỗi: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
