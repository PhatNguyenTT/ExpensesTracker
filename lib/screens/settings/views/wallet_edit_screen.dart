import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';
import 'package:expenses_tracker/screens/settings/blocs/wallet_blocs/update_wallet_bloc/update_wallet_bloc.dart';
import 'package:expenses_tracker/utils/category_icon_picker.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expenses_tracker/utils/wallet_icon_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class WalletEditScreen extends StatefulWidget {
  final Wallet wallet;

  const WalletEditScreen({super.key, required this.wallet});

  @override
  State<WalletEditScreen> createState() => _WalletEditScreenState();
}

class _WalletEditScreenState extends State<WalletEditScreen> {
  late TextEditingController _nameController;
  late Color _selectedColor;
  late IconData? _selectedIcon;
  bool _isLoading = false;
  bool _isIconExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.wallet.name);
    _selectedColor = widget.wallet.color;
    _selectedIcon = IconMapper.getIcon(widget.wallet.icon);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateWalletBloc, UpdateWalletState>(
      listener: (context, state) {
        if (state is UpdateWalletLoading) {
          setState(() => _isLoading = true);
        } else if (state is UpdateWalletSuccess) {
          Navigator.of(context).pop(true); // Pop with a success flag
        } else if (state is UpdateWalletFailure) {
          setState(() => _isLoading = false);
          // Show error dialog or snackbar
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Chỉnh sửa ví tiền',
              style: TextStyle(color: Colors.black87)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Tên ví'),
              const SizedBox(height: 12),
              _buildNameField(),
              const SizedBox(height: 24),
              _buildSectionTitle('Biểu tượng'),
              const SizedBox(height: 12),
              _buildIconField(),
              if (_isIconExpanded) _buildIconGrid(),
              const SizedBox(height: 24),
              _buildSectionTitle('Màu sắc'),
              const SizedBox(height: 12),
              _buildColorField(),
              const SizedBox(height: 40),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        hintText: 'Nhập tên ví',
      ),
    );
  }

  Widget _buildIconField() {
    return GestureDetector(
      onTap: () => setState(() => _isIconExpanded = !_isIconExpanded),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_selectedIcon ?? Icons.help, color: _selectedColor),
            const SizedBox(width: 16),
            const Expanded(child: Text('Chọn biểu tượng')),
            Icon(_isIconExpanded
                ? CupertinoIcons.chevron_up
                : CupertinoIcons.chevron_down),
          ],
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: IconPickerGrid(
        icons: walletIcons,
        scrollController: _scrollController,
        selectedIcon: _selectedIcon,
        onIconSelected: (icon) {
          setState(() {
            _selectedIcon = icon;
            _isIconExpanded = false;
          });
        },
      ),
    );
  }

  Widget _buildColorField() {
    return GestureDetector(
      onTap: _showColorPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: _selectedColor, shape: BoxShape.circle)),
            const SizedBox(width: 16),
            const Expanded(child: Text('Tùy chỉnh màu sắc')),
            const Icon(Icons.color_lens),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveWallet,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Chọn màu'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) => setState(() => _selectedColor = color),
          ),
        ),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Chọn'))
        ],
      ),
    );
  }

  void _saveWallet() {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return; // Basic validation

    final updatedWallet = widget.wallet.copyWith(
      name: newName,
      color: _selectedColor,
      icon: IconMapper.getName(_selectedIcon!),
    );
    context.read<UpdateWalletBloc>().add(UpdateWallet(updatedWallet));
  }
}
