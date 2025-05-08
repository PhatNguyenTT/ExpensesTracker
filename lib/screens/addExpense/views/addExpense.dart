import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart' as tt;
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/categoryCreation.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';
import 'package:flutter/material.dart';
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
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    expense = widget.expenseToEdit?.copyWith() ?? Expense.empty;

    if (widget.expenseToEdit != null) {
      expenseController.text = expense.amount.toString();
      noteController.text = expense.note ?? '';
      categoryController.text = expense.category.name;
      dateController.text = DateFormat('dd/MM/yyyy').format(expense.date);
    } else {
      // 💡 RESET FULL khi là tạo mới
      expense.expenseId = const Uuid().v1();
      expense.date = DateTime.now();
      expense.category = Category.empty;
      categoryController.clear();
    }

<<<<<<< HEAD
    final isEditingIncome =
        widget.expenseToEdit?.category.type == tt.TransactionType.income;
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: isEditingIncome ? 1 : 0);
=======
    _tabController = TabController(length: 2, vsync: this);
>>>>>>> origin/main
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
    return BlocListener<CreateExpenseBloc, CreateExpenseState>(
      listener: (context, state) {
        if (state is CreateExpenseSuccess) {
          Navigator.pop(context, expense);
        } else if (state is CreateExpenseLoading) {
          setState(() {
            isLoading = true;
          });
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'Chi tiêu'),
                Tab(text: 'Thu nhập'),
              ],
            ),
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                final filteredCategories = state.categories
                    .where((c) => c.type == selectedType)
                    .toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Thêm Giao Dịch',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          controller: expenseController,
                          textAlignVertical: TextAlignVertical.center,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              FontAwesomeIcons.dongSign,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: categoryController,
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        onTap: () async {},
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: expense.category == Category.empty
                              ? Colors.white
                              : expense.category.color,
                          prefixIcon: expense.category == Category.empty
                              ? Icon(
                                  FontAwesomeIcons.list,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.outline,
                                )
                              : Icon(
                                  IconMapper.getIcon(expense.category.icon) ??
                                      Icons.help,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                          suffixIcon: IconButton(
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
                            icon: Icon(
                              FontAwesomeIcons.plus,
                              size: 16,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          hintText: 'Danh mục',
                          border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      Container(
                        height: 200,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(12)),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filteredCategories.length,
                            itemBuilder: (context, i) {
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      expense.category = filteredCategories[i];
                                      categoryController.text =
                                          expense.category.name;
                                    });
                                  },
                                  leading: Icon(
                                    IconMapper.getIcon(
                                            filteredCategories[i].icon) ??
                                        Icons.help_outline,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  title: Text(filteredCategories[i].name),
                                  tileColor: filteredCategories[i].color,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: noteController,
                        onChanged: (value) => expense.note = value,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Ghi chú',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: dateController,
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: expense.date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (newDate != null) {
                            setState(() {
                              dateController.text =
                                  DateFormat('dd/MM/yyyy').format(newDate);
                              expense.date = newDate;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            FontAwesomeIcons.clock,
                            size: 16,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          hintText: 'Ngày',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: kToolbarHeight,
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : TextButton(
                                onPressed: () {
                                  final amount =
                                      int.tryParse(expenseController.text) ?? 0;
                                  setState(() {
                                    expense.amount = amount;
                                    expense.category.totalExpenses =
                                        expense.category.type ==
                                                tt.TransactionType.income
                                            ? amount
                                            : -amount;
                                  });
                                  context
                                      .read<CreateExpenseBloc>()
                                      .add(CreateExpense(expense));
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Lưu',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
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
}
