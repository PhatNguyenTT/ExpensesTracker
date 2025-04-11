import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/addExpense/views/addExpense.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/delete/delete_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/update/update_expense_bloc.dart';
import 'package:expenses_tracker/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';

class ViewAllExpenses extends StatefulWidget {
  final List<Expense> expenses;
  const ViewAllExpenses({super.key, required this.expenses});

  @override
  State<ViewAllExpenses> createState() => _ViewAllExpensesState();
}

class _ViewAllExpensesState extends State<ViewAllExpenses> {
  String searchQuery = '';
  bool isEditing = false;

  Future<Expense?> _navigateToAddExpense(BuildContext context, Expense? e) {
    return Navigator.push<Expense>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => UpdateExpenseBloc(FirebaseExpenseRepo()),
            ),
            BlocProvider(
              create: (context) => CreateExpenseBloc(FirebaseExpenseRepo()),
            ),
            BlocProvider(
              create: (context) => GetCategoriesBloc(FirebaseExpenseRepo())
                ..add(GetCategories()),
            ),
          ],
          child: AddExpense(expenseToEdit: e),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.expenses.where((e) {
      return e.category.name
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          (e.note?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
    }).toList();

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
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            TextButton(
              onPressed: () => setState(() => isEditing = !isEditing),
              child: Text(isEditing ? 'Xong' : 'Chỉnh sửa'),
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
                  final sum = expenses.fold<int>(0, (a, b) => a + b.amount);

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
                            Text(formatSignedCurrency(sum),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: getAmountColor(sum))),
                          ],
                        ),
                      ),
                      ...expenses.map((e) {
                        final iconData = IconMapper.getIcon(e.category.icon);
                        return ListTile(
                          onTap: () async {
                            if (!isEditing) return;
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
                          },
                          leading: CircleAvatar(
                            backgroundColor: e.category.color,
                            radius: 24,
                            child: iconData != null
                                ? Icon(iconData,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary)
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
                          trailing: isEditing
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () async {
                                        final updated =
                                            await _navigateToAddExpense(
                                                context, e);
                                        if (updated != null) {
                                          context.read<UpdateExpenseBloc>().add(
                                              UpdateExpenseRequested(updated));
                                          setState(() {
                                            final index = widget.expenses
                                                .indexWhere((exp) =>
                                                    exp.expenseId ==
                                                    updated.expenseId);
                                            if (index != -1) {
                                              widget.expenses[index] = updated;
                                            }
                                          });
                                        }
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () async {
                                        final result = await showDialog(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            title: const Text('Xác nhận'),
                                            content: const Text(
                                                'Bạn có chắc muốn xóa giao dịch này không?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, false),
                                                  child: const Text('Huỷ')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, true),
                                                  child: const Text('Xóa')),
                                            ],
                                          ),
                                        );

                                        if (result == true) {
                                          context.read<DeleteExpenseBloc>().add(
                                              DeleteExpenseRequested(
                                                  e.expenseId));

                                          setState(() {
                                            widget.expenses.remove(e);
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                )
                              : null,
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
