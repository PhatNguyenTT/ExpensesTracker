import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/addExpense/views/addExpense.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/delete/delete_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/update/update_expense_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';

enum SortOption {
  newestFirst,
  oldestFirst,
  balanceDescending,
}

class ViewAllExpenses extends StatefulWidget {
  final List<Expense> expenses;
  const ViewAllExpenses({super.key, required this.expenses});

  @override
  State<ViewAllExpenses> createState() => _ViewAllExpensesState();
}

class _ViewAllExpensesState extends State<ViewAllExpenses> {
  String searchQuery = '';
  bool isEditing = false;

  SortOption sortOption = SortOption.newestFirst; // Mặc định

  Future<Expense?> _navigateToAddExpense(BuildContext context, Expense? e) {
    return Navigator.push<Expense>(context, MaterialPageRoute(builder: (_) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => UpdateExpenseBloc(FirebaseExpenseRepo())),
          BlocProvider(
              create: (context) => CreateExpenseBloc(FirebaseExpenseRepo())),
          BlocProvider(
              create: (context) => GetCategoriesBloc(FirebaseExpenseRepo())
                ..add(GetCategories())),
        ],
        child: AddExpense(expenseToEdit: e),
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.expenses.where((e) {
      return e.category.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (e.note?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }).toList();

    switch (sortOption) {
      case SortOption.newestFirst:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.oldestFirst:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.balanceDescending:
        filtered.sort((a, b) {
          final aDate = DateFormat('dd/MM/yyyy').format(a.date);
          final bDate = DateFormat('dd/MM/yyyy').format(b.date);

          final aTotal = widget.expenses
              .where((e) => DateFormat('dd/MM/yyyy').format(e.date) == aDate)
              .fold<int>(
                  0,
                  (sum, e) =>
                      sum +
                      (e.category.type.name == 'income'
                          ? e.amount
                          : -e.amount));

          final bTotal = widget.expenses
              .where((e) => DateFormat('dd/MM/yyyy').format(e.date) == bDate)
              .fold<int>(
                  0,
                  (sum, e) =>
                      sum +
                      (e.category.type.name == 'income'
                          ? e.amount
                          : -e.amount));

          return bTotal.compareTo(aTotal); // số dư lớn hơn đứng trước
        });
        break;
    }

    final Map<String, List<Expense>> grouped = {};
    for (var expense in filtered) {
      final dateKey = DateFormat('dd/MM/yyyy').format(expense.date);
      grouped.putIfAbsent(dateKey, () => []).add(expense);
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteExpenseBloc, DeleteExpenseState>(
          listener: (context, state) {
            if (state is DeleteExpenseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Xóa giao dịch thành công')),
              );
            } else if (state is DeleteExpenseFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi: ${state.error}')),
              );
            }
          },
        ),
        BlocListener<UpdateExpenseBloc, UpdateExpenseState>(
          listener: (context, state) {
            if (state is UpdateExpenseSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cập nhật giao dịch thành công')),
              );
            } else if (state is UpdateExpenseFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi khi cập nhật: ${state.error}')),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tất cả giao dịch'),
          actions: [
            PopupMenuButton<SortOption>(
              onSelected: (value) => setState(() => sortOption = value),
              icon: const Icon(Icons.sort),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: SortOption.newestFirst,
                  child: Text('Mới → Cũ'),
                ),
                const PopupMenuItem(
                  value: SortOption.oldestFirst,
                  child: Text('Cũ → Mới'),
                ),
                const PopupMenuItem(
                  value: SortOption.balanceDescending,
                  child: Text('Số dư'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) => setState(() => searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên danh mục... hoặc ghi chú',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: grouped.entries.map((entry) {
                  final date = entry.key;
                  final expenses = entry.value;

                  // Tính tổng tiền và số giao dịch trong ngày
                  final sum = expenses.fold<int>(0, (a, b) {
                    final isExpense =
                        b.category.type.toString().contains('expense');
                    return a + (isExpense ? -b.amount : b.amount);
                  });

                  final numTransactions = expenses.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(date,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            RichText(
                              text: TextSpan(
                                text:
                                    '${sum >= 0 ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(sum.abs())} ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: sum >= 0 ? Colors.green : Colors.red,
                                ),
                                children: [
                                  TextSpan(
                                    text: '• $numTransactions giao dịch',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...expenses.map((e) {
                        final iconData = IconMapper.getIcon(e.category.icon);
                        return Dismissible(
                          key: Key(e.expenseId),
                          background: Container(
                            color: Colors.blue,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              // Vuốt trái → phải: Sửa
                              final updated =
                                  await _navigateToAddExpense(context, e);
                              if (updated != null) {
                                context
                                    .read<UpdateExpenseBloc>()
                                    .add(UpdateExpenseRequested(updated));
                                setState(() {
                                  final index = widget.expenses.indexWhere(
                                      (exp) =>
                                          exp.expenseId == updated.expenseId);
                                  if (index != -1) {
                                    widget.expenses[index] = updated;
                                  }
                                });
                              }
                              return false; // Không xóa
                            } else {
                              // Vuốt phải → trái: Xóa
                              final result = await showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Xác nhận'),
                                  content: const Text(
                                      'Bạn có chắc muốn xóa giao dịch này không?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Huỷ')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Xóa')),
                                  ],
                                ),
                              );
                              if (result == true) {
                                context
                                    .read<DeleteExpenseBloc>()
                                    .add(DeleteExpenseRequested(e.expenseId));
                                setState(() {
                                  widget.expenses.remove(e);
                                });
                              }
                              return result;
                            }
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: e.category.color,
                              radius: 24,
                              child: iconData != null
                                  ? Icon(iconData,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Text(e.category.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                if (e.note != null && e.note!.isNotEmpty)
                                  Text(' (${e.note})',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                            subtitle:
                                Text(DateFormat('dd/MM/yyyy').format(e.date)),
                            trailing: Text(
                              '${e.category.type.name == 'income' ? '+' : '-'}${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(e.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: e.category.type.name == 'income'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
