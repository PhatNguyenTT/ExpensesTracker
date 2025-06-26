import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/categoryCreation.dart';
import 'package:expenses_tracker/screens/home/blocs/active_wallet_bloc/active_wallet_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/delete/delete_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/update/update_expense_bloc.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpense({super.key, this.expenseToEdit});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense>
    with SingleTickerProviderStateMixin {
  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  late Expense expense;
  bool isLoading = false;
  late TabController _tabController;
  tt.TransactionType selectedType = tt.TransactionType.expense;

  @override
  void initState() {
    super.initState();
    // Ensure the BLoC state is read after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final activeWalletState = context.read<ActiveWalletBloc>().state;
      String activeWalletId = '';
      if (activeWalletState is ActiveWalletLoaded) {
        activeWalletId = activeWalletState.activeWallet.walletId;
      }

      setState(() {
        dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
        expense = widget.expenseToEdit?.copyWith() ??
            Expense.empty.copyWith(walletId: activeWalletId);

        if (widget.expenseToEdit != null) {
          expenseController.text =
              NumberFormat('#,###', 'vi_VN').format(expense.amount);
          noteController.text = expense.note ?? '';
          categoryController.text = expense.category.name;
          dateController.text = DateFormat('dd/MM/yyyy').format(expense.date);
        } else {
          expense.expenseId = const Uuid().v1();
          expense.date = DateTime.now();
          expense.category = Category.empty;
          expense.walletId = activeWalletId;
          categoryController.clear();
        }

        final isEditingIncome =
            widget.expenseToEdit?.category.type == tt.TransactionType.income;
        _tabController.index = isEditingIncome ? 1 : 0;
      });
    });

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        selectedType = _tabController.index == 0
            ? tt.TransactionType.expense
            : tt.TransactionType.income;
        expense.category = Category.empty;
        categoryController.clear();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<CreateExpenseBloc, CreateExpenseState>(
            listener: (context, state) {
              if (state is CreateExpenseSuccess) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Thêm giao dịch thành công'),
                    backgroundColor: Colors.green));
                Navigator.pop(context, state.expense);
              } else if (state is CreateExpenseFailure) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Thêm giao dịch thất bại'),
                    backgroundColor: Colors.red));
              } else if (state is CreateExpenseLoading) {
                setState(() => isLoading = true);
              }
            },
          ),
          BlocListener<UpdateExpenseBloc, UpdateExpenseState>(
            listener: (context, state) {
              if (state is UpdateExpenseSuccess) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Cập nhật giao dịch thành công'),
                    backgroundColor: Colors.green));
                Navigator.pop(context, state.expense);
              } else if (state is UpdateExpenseFailure) {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Cập nhật thất bại: ${state.error}'),
                    backgroundColor: Colors.red));
              } else if (state is UpdateExpenseLoading) {
                setState(() => isLoading = true);
              }
            },
          ),
          BlocListener<DeleteExpenseBloc, DeleteExpenseState>(
            listener: (context, state) {
              if (state is DeleteExpenseLoading) {
                setState(() => isLoading = true);
              } else {
                setState(() => isLoading = false);
              }

              if (state is DeleteExpenseSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Xóa giao dịch thành công'),
                    backgroundColor: Colors.green));
                Navigator.pop(context, state.expenseId);
              } else if (state is DeleteExpenseFailure) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Xóa thất bại: ${state.error}'),
                    backgroundColor: Colors.red));
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: Text(
              widget.expenseToEdit != null
                  ? 'Chỉnh sửa giao dịch'
                  : 'Thêm giao dịch',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (widget.expenseToEdit != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context);
                  },
                )
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey[600],
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Chi tiêu'),
                    Tab(text: 'Thu nhập'),
                  ],
                ),
              ),
            ),
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                final filteredCategories = state.categories
                    .where((c) => c.type == selectedType)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount Section với header
                      const Text(
                        'Số tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              selectedType == tt.TransactionType.income
                                  ? 'Thu nhập'
                                  : 'Chi tiêu',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: expenseController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                _CurrencyInputFormatter(),
                              ],
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[300],
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Category Section
                      const Text(
                        'Danh mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Selected Category Display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: expense.category != Category.empty
                                ? expense.category.color.withOpacity(0.3)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: expense.category == Category.empty
                                    ? Colors.grey[100]
                                    : expense.category.color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                expense.category == Category.empty
                                    ? Icons.category_outlined
                                    : IconMapper.getIcon(
                                            expense.category.icon) ??
                                        Icons.help,
                                color: expense.category == Category.empty
                                    ? Colors.grey[400]
                                    : expense.category.color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    expense.category == Category.empty
                                        ? 'Chọn danh mục'
                                        : expense.category.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: expense.category == Category.empty
                                          ? Colors.grey[600]
                                          : Colors.black87,
                                    ),
                                  ),
                                  if (expense.category != Category.empty)
                                    Text(
                                      selectedType == tt.TransactionType.income
                                          ? 'Thu nhập'
                                          : 'Chi tiêu',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                var newCategory = await getCategoryCreation(
                                    context, selectedType);
                                if (newCategory != null &&
                                    newCategory.type == selectedType) {
                                  setState(() {
                                    final safeNewCategory =
                                        newCategory.copyWith();
                                    state.categories.insert(0, safeNewCategory);
                                  });
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Categories Grid
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Danh mục ${selectedType == tt.TransactionType.income ? "thu nhập" : "chi tiêu"}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, i) {
                                final category = filteredCategories[i];
                                final isSelected =
                                    expense.category.categoryId ==
                                        category.categoryId;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      expense.category = category;
                                      categoryController.text = category.name;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? category.color.withOpacity(0.2)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? category.color
                                            : Colors.grey[200]!,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          IconMapper.getIcon(category.icon) ??
                                              Icons.help_outline,
                                          color: isSelected
                                              ? category.color
                                              : Colors.grey[600],
                                          size: 24,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? category.color
                                                : Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Note and Date Section
                      Row(
                        children: [
                          // Note Field
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ghi chú',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    controller: noteController,
                                    onChanged: (value) => expense.note = value,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: 'Thêm ghi chú...',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Date Field
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ngày',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () async {
                                    DateTime? newDate = await showDatePicker(
                                      context: context,
                                      initialDate: expense.date,
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2100),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: selectedType ==
                                                      tt.TransactionType.income
                                                  ? Colors.green
                                                  : Colors.red,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.black,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (newDate != null) {
                                      setState(() {
                                        expense.date = newDate;
                                      });
                                    }
                                  },
                                  child: Container(
                                    height: 85,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Colors.grey[600],
                                          size: 20,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          DateFormat('dd/MM')
                                              .format(expense.date),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('yyyy')
                                              .format(expense.date),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Save Button
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: selectedType == tt.TransactionType.income
                                ? [Colors.green, Colors.green.shade600]
                                : [Colors.red, Colors.red.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (selectedType == tt.TransactionType.income
                                      ? Colors.green
                                      : Colors.red)
                                  .withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    final amount = int.tryParse(
                                            expenseController.text
                                                .replaceAll('.', '')) ??
                                        0;
                                    if (amount <= 0) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Vui lòng nhập số tiền hợp lệ'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }
                                    if (expense.category == Category.empty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content:
                                              Text('Vui lòng chọn danh mục'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    setState(() {
                                      expense.amount = amount;
                                      expense.category.totalExpenses =
                                          expense.category.type ==
                                                  tt.TransactionType.income
                                              ? amount
                                              : -amount;
                                    });
                                    if (widget.expenseToEdit != null) {
                                      setState(() => isLoading = true);
                                      final updateBloc =
                                          context.read<UpdateExpenseBloc>();
                                      updateBloc
                                          .add(UpdateExpenseRequested(expense));
                                    } else {
                                      setState(() => isLoading = true);
                                      final createBloc =
                                          context.read<CreateExpenseBloc>();
                                      createBloc.add(CreateExpense(expense));
                                    }
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          widget.expenseToEdit != null
                                              ? Icons.edit
                                              : Icons.add,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          widget.expenseToEdit != null
                                              ? 'Cập nhật giao dịch'
                                              : 'Thêm giao dịch',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext buildContext) {
    showDialog(
        context: buildContext,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Xóa giao dịch?'),
            content: const Text('Bạn có chắc muốn xóa giao dịch này không?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy')),
              TextButton(
                onPressed: () {
                  final deleteBloc = buildContext.read<DeleteExpenseBloc>();
                  deleteBloc.add(
                      DeleteExpenseRequested(widget.expenseToEdit!.expenseId));
                  // chỉ đóng dialog, form sẽ tự đóng khi nhận DeleteExpenseSuccess
                  Navigator.pop(dialogContext);
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              )
            ],
          );
        });
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
