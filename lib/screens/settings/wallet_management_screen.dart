import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';
import 'package:expenses_tracker/screens/settings/blocs/wallet_blocs/create_wallet_bloc/create_wallet_bloc.dart';
import 'package:expenses_tracker/screens/settings/blocs/wallet_blocs/delete_wallet_bloc/delete_wallet_bloc.dart';
import 'package:expenses_tracker/screens/settings/blocs/wallet_blocs/get_wallets_bloc/get_wallets_bloc.dart';
import 'package:expenses_tracker/screens/settings/blocs/wallet_blocs/update_wallet_bloc/update_wallet_bloc.dart';
import 'package:expenses_tracker/screens/settings/views/wallet_creation.dart';
import 'package:expenses_tracker/utils/category_icon_picker.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:expenses_tracker/utils/wallet_icon_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class WalletManagementScreen extends StatefulWidget {
  const WalletManagementScreen({super.key});

  @override
  State<WalletManagementScreen> createState() => _WalletManagementScreenState();
}

class _WalletManagementScreenState extends State<WalletManagementScreen> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetWalletsBloc(context.read<ExpenseRepository>())
            ..add(GetWallets()),
        ),
        BlocProvider(
          create: (context) =>
              CreateWalletBloc(context.read<ExpenseRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              DeleteWalletBloc(context.read<ExpenseRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              UpdateWalletBloc(context.read<ExpenseRepository>()),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<CreateWalletBloc, CreateWalletState>(
            listener: (context, state) {
              if (state is CreateWalletSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tạo ví thành công!'),
                      backgroundColor: Colors.green),
                );
                context.read<GetWalletsBloc>().add(GetWallets());
              } else if (state is CreateWalletFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Tạo ví thất bại.'),
                      backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<DeleteWalletBloc, DeleteWalletState>(
            listener: (context, state) {
              if (state is DeleteWalletSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Xóa ví thành công!'),
                      backgroundColor: Colors.green),
                );
                context.read<GetWalletsBloc>().add(GetWallets());
              } else if (state is DeleteWalletFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Xóa ví thất bại: ${state.message}'),
                      backgroundColor: Colors.red),
                );
              }
            },
          ),
          BlocListener<UpdateWalletBloc, UpdateWalletState>(
            listener: (context, state) {
              if (state is UpdateWalletSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Cập nhật ví thành công!'),
                      backgroundColor: Colors.green),
                );
                context.read<GetWalletsBloc>().add(GetWallets());
              } else if (state is UpdateWalletFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Cập nhật ví thất bại: ${state.message}'),
                      backgroundColor: Colors.red),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              'Quản lý ví tiền',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    isEditMode = !isEditMode;
                  });
                },
                child: Text(
                  isEditMode ? 'Xong' : 'Chỉnh sửa',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          body: BlocBuilder<GetWalletsBloc, GetWalletsState>(
            builder: (context, state) {
              if (state is GetWalletsLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetWalletsFailure) {
                return const Center(child: Text('Không thể tải ví.'));
              }
              if (state is GetWalletsSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (!isEditMode) ...[
                        _buildAddItem(context),
                        const SizedBox(height: 16),
                      ],
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.wallets.length,
                          itemBuilder: (context, index) {
                            final wallet = state.wallets[index];
                            return _buildWalletItem(
                                context, wallet, isEditMode);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: Text('Trạng thái không xác định.'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAddItem(BuildContext context) {
    return InkWell(
      onTap: () async {
        final newWallet = await getWalletCreationDialog(context);
        if (newWallet != null && context.mounted) {
          context.read<CreateWalletBloc>().add(CreateWallet(newWallet));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Thêm ví mới'),
            SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletItem(BuildContext context, Wallet wallet, bool isEditing) {
    return InkWell(
      onTap: isEditing
          ? null
          : () async {
              final updatedWallet = await getWalletEditDialog(context, wallet);
              if (updatedWallet != null && context.mounted) {
                context
                    .read<UpdateWalletBloc>()
                    .add(UpdateWallet(updatedWallet));
              }
            },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: wallet.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                IconMapper.getIcon(wallet.icon),
                color: wallet.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Số dư ban đầu: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(wallet.initialBalance)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isEditing)
              IconButton(
                onPressed: () {
                  _showDeleteDialog(context, wallet);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              )
            else
              const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Wallet wallet) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa ví'),
        content: Text(
            'Bạn có chắc muốn xóa ví "${wallet.name}"?\nTất cả các giao dịch liên quan cũng sẽ bị xóa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<DeleteWalletBloc>()
                  .add(DeleteWallet(wallet.walletId));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

Future<Wallet?> getWalletEditDialog(BuildContext context, Wallet walletToEdit) {
  return showDialog<Wallet>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final nameController = TextEditingController(text: walletToEdit.name);
      IconData? selectedIcon = IconMapper.getIcon(walletToEdit.icon);
      Color selectedColor = walletToEdit.color;
      bool isIconExpanded = false;
      final scrollController = ScrollController();

      return StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: const Text('Chỉnh sửa ví', textAlign: TextAlign.center),
            content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(nameController, 'Tên ví', ''),
                      const SizedBox(height: 20),
                      _buildIconPicker(
                          ctx,
                          setState,
                          selectedIcon,
                          selectedColor,
                          isIconExpanded,
                          scrollController, (icon) {
                        setState(() {
                          selectedIcon = icon;
                          isIconExpanded = false;
                        });
                      },
                          () =>
                              setState(() => isIconExpanded = !isIconExpanded)),
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
                )),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedWallet = _validateAndBuildUpdatedWallet(
                    ctx,
                    walletToEdit,
                    nameController,
                    selectedIcon,
                    selectedColor,
                  );
                  if (updatedWallet != null) {
                    Navigator.of(ctx).pop(updatedWallet);
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      );
    },
  );
}

Wallet? _validateAndBuildUpdatedWallet(
  BuildContext context,
  Wallet originalWallet,
  TextEditingController nameController,
  IconData? selectedIcon,
  Color selectedColor,
) {
  if (nameController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vui lòng nhập tên ví.')),
    );
    return null;
  }

  return originalWallet.copyWith(
    name: nameController.text.trim(),
    icon: IconMapper.getName(selectedIcon ?? Icons.wallet_outlined) ?? 'wallet',
    color: selectedColor,
  );
}

// Re-using helper widgets from wallet_creation
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
