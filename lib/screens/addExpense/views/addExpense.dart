import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/categoryCreation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class AddExpense extends StatefulWidget {
  const AddExpense({super.key});

  @override
  State<AddExpense> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController expenseController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  late Expense expense;
  bool isLoading = false;
  bool isIncome = false;

  List<String> myCategoriesIcons = [
    'entertainment',
    'food',
    'home',
    'pet',
    'shopping',
    'tech',
    'travel',
  ];

  @override
  void initState() {
    dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
    expense = Expense.empty;
    expense.expenseId = const Uuid().v1();
    super.initState();
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
          ),
          body: BlocBuilder<GetCategoriesBloc, GetCategoriesState>(
            builder: (context, state) {
              if (state is GetCategoriesSuccess) {
                return Padding(
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
                      // const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: const Text("Chi tiêu"),
                            selected: !isIncome,
                            onSelected: (_) {
                              setState(() => isIncome = false);
                            },
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text("Thu nhập"),
                            selected: isIncome,
                            onSelected: (_) {
                              setState(() => isIncome = true);
                            },
                          ),
                        ],
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
                              : Image.asset(
                                  'assets/${expense.category.icon}.png',
                                  scale: 2,
                                ),
                          suffixIcon: IconButton(
                            onPressed: () async {
                              var newCategory =
                                  await getCategoryCreation(context);
                              setState(() {
                                state.categories.insert(0, newCategory);
                              });
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
                            bottom: Radius.circular(12),
                          ),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemCount: state.categories.length,
                            itemBuilder: (context, i) {
                              return Card(
                                child: ListTile(
                                  onTap: () {
                                    setState(() {
                                      expense.category = state.categories[i];
                                      categoryController.text =
                                          expense.category.name;
                                    });
                                  },
                                  leading: Image.asset(
                                    'assets/${state.categories[i].icon}.png',
                                    scale: 2,
                                  ),
                                  title: Text(state.categories[i].name),
                                  tileColor: state.categories[i].color,
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
                        controller: dateController,
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        onTap: () async {
                          DateTime? newDate = await showDatePicker(
                            context: context,
                            initialDate: expense.date,
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
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
                                      int.parse(expenseController.text);
                                  setState(() {
                                    expense.amount = amount;
                                    expense.category.totalExpenses =
                                        isIncome ? amount : -amount;
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
