import 'package:expenses_tracker/screens/settings/blocs/initial_balance_bloc/initial_balance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expense_repository/expense_repository.dart';

class InitialBalanceScreen extends StatelessWidget {
  const InitialBalanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bloc đã được cung cấp ở tầng trên, chỉ cần sử dụng
    return const InitialBalanceView();
  }
}

class InitialBalanceView extends StatefulWidget {
  const InitialBalanceView({super.key});

  @override
  State<InitialBalanceView> createState() => _InitialBalanceViewState();
}

class _InitialBalanceViewState extends State<InitialBalanceView> {
  final _dialogFormKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Kích hoạt việc tải dữ liệu khi màn hình được khởi tạo
    context.read<InitialBalanceBloc>().add(LoadInitialBalance());
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSave(BuildContext context) {
    if (_dialogFormKey.currentState!.validate()) {
      final amount =
          int.tryParse(_amountController.text.replaceAll('.', '')) ?? 0;

      context.read<InitialBalanceBloc>().add(
            SetInitialBalance(
                amount: amount, note: 'Cập nhật từ màn hình cài đặt'),
          );
      Navigator.of(context).pop(); // Đóng dialog sau khi lưu
    }
  }

  void _showEditBalanceDialog(
      BuildContext context, InitialBalanceLoaded state) {
    final currentAmount = state.initialBalance?.amount ?? 0;
    _amountController.text = _CurrencyInputFormatter()
        .formatEditUpdate(
          TextEditingValue.empty,
          TextEditingValue(text: currentAmount.toString()),
        )
        .text;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Số dư ban đầu',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Form(
            key: _dialogFormKey,
            child: TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _CurrencyInputFormatter(),
              ],
              decoration: const InputDecoration(
                hintText: 'Nhập số tiền',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số dư';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Bỏ qua',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => _onSave(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('Số dư ban đầu'),
        centerTitle: true,
      ),
      body: BlocListener<InitialBalanceBloc, InitialBalanceState>(
        listener: (context, state) {
          if (state is InitialBalanceSetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Số dư ban đầu đã được cập nhật!'),
                backgroundColor: Colors.green,
              ),
            );
            // Tải lại dữ liệu sau khi cập nhật thành công
            context.read<InitialBalanceBloc>().add(LoadInitialBalance());
          } else if (state is InitialBalanceFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${state.error}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<InitialBalanceBloc, InitialBalanceState>(
          builder: (context, state) {
            if (state is! InitialBalanceLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final currentBalance = state.initialBalance?.amount ?? 0;
            final formattedBalance =
                NumberFormat.currency(locale: 'vi_VN', symbol: '₫')
                    .format(currentBalance);

            return Container(
              color: Colors.white,
              margin: const EdgeInsets.all(16.0),
              child: ListTile(
                title: const Text(
                  'Số dư ban đầu',
                  style: TextStyle(fontSize: 16),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formattedBalance,
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
                onTap: () {
                  _showEditBalanceDialog(context, state);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final intValue = int.tryParse(newValue.text.replaceAll('.', '')) ?? 0;
    final formatter = NumberFormat('#,###', 'vi_VN');
    String newText = formatter.format(intValue);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
