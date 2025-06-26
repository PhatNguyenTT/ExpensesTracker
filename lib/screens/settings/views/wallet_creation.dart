import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';
import 'package:expenses_tracker/utils/category_icon_picker.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expenses_tracker/utils/wallet_icon_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

Future<Wallet?> getWalletCreationDialog(BuildContext context) {
  return showDialog<Wallet>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final nameController = TextEditingController();
      final balanceController = TextEditingController();
      IconData? selectedIcon = Icons.wallet_outlined;
      Color selectedColor = Colors.blue;
      bool isIconExpanded = false;
      final scrollController = ScrollController();

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Tạo ví mới', textAlign: TextAlign.center),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(nameController, 'Tên ví', 'Ví tiền mặt'),
                    const SizedBox(height: 20),
                    _buildTextField(balanceController, 'Số dư ban đầu', '0',
                        isNumeric: true),
                    const SizedBox(height: 20),
                    _buildIconPicker(ctx, setState, selectedIcon, selectedColor,
                        isIconExpanded, scrollController, (icon) {
                      setState(() {
                        selectedIcon = icon;
                        isIconExpanded = false;
                      });
                    }, () => setState(() => isIconExpanded = !isIconExpanded)),
                    if (isIconExpanded)
                      _buildIconGrid(scrollController, selectedIcon, (icon) {
                        setState(() {
                          selectedIcon = icon;
                          isIconExpanded = false;
                        });
                      }),
                    const SizedBox(height: 20),
                    _buildColorPicker(ctx, setState, selectedColor,
                        (color) => setState(() => selectedColor = color)),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child:
                    Text('Hủy', style: TextStyle(color: Colors.grey.shade700)),
              ),
              ElevatedButton(
                onPressed: () {
                  final newWallet = _validateAndBuildWallet(
                    ctx,
                    nameController,
                    balanceController,
                    selectedIcon,
                    selectedColor,
                  );
                  if (newWallet != null) {
                    Navigator.of(ctx).pop(newWallet);
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text('Tạo'),
              ),
            ],
          );
        },
      );
    },
  );
}

Widget _buildTextField(
    TextEditingController controller, String label, String hint,
    {bool isNumeric = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumeric
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  _CurrencyInputFormatter()
                ]
              : [],
          decoration: InputDecoration(
            isDense: true,
            filled: false,
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    ],
  );
}

Widget _buildIconPicker(
    BuildContext context,
    StateSetter setState,
    IconData? selectedIcon,
    Color selectedColor,
    bool isExpanded,
    ScrollController controller,
    Function(IconData) onSelect,
    VoidCallback onToggle) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Biểu tượng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: Radius.circular(isExpanded ? 0 : 12),
              bottomRight: Radius.circular(isExpanded ? 0 : 12),
            ),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selectedColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(selectedIcon, color: selectedColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(selectedIcon != null
                      ? 'Biểu tượng đã chọn'
                      : 'Chọn biểu tượng')),
              Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  size: 16),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildIconGrid(ScrollController controller, IconData? selectedIcon,
    Function(IconData) onSelect) {
  return Container(
    height: 280,
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: IconPickerGrid(
        icons: walletIcons,
        scrollController: controller,
        selectedIcon: selectedIcon,
        onIconSelected: onSelect,
      ),
    ),
  );
}

Widget _buildColorPicker(BuildContext context, StateSetter setState,
    Color color, Function(Color) onColorChanged) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Màu sắc',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Chọn màu sắc'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: color,
                onColorChanged: (newColor) =>
                    setState(() => onColorChanged(newColor)),
              ),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Chọn'))
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(8))),
              const SizedBox(width: 12),
              const Expanded(child: Text('Tùy chỉnh màu sắc')),
              Icon(Icons.color_lens, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    ],
  );
}

Wallet? _validateAndBuildWallet(
  BuildContext context,
  TextEditingController nameController,
  TextEditingController balanceController,
  IconData? selectedIcon,
  Color selectedColor,
) {
  if (nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Vui lòng nhập tên ví.'), backgroundColor: Colors.red),
    );
    return null;
  }

  final balance = int.tryParse(balanceController.text.replaceAll('.', '')) ?? 0;

  return Wallet(
    walletId: const Uuid().v1(),
    name: nameController.text.trim(),
    initialBalance: balance,
    icon: IconMapper.getName(selectedIcon ?? Icons.wallet_outlined) ?? 'wallet',
    color: selectedColor,
    dateCreated: DateTime.now(),
  );
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
