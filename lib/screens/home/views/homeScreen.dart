import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/get/get_expenses_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/get_summary_bloc/get_summary_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/addExpense.dart';
import 'package:expenses_tracker/screens/calendar/calendarScreen.dart';
import 'package:expenses_tracker/screens/home/views/mainScreen.dart';
import 'package:expenses_tracker/screens/settings/settings_screen.dart';
import 'package:expenses_tracker/screens/stats/statsScreen.dart';
import 'package:expenses_tracker/screens/stats/stats_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Khi có expense mới được tạo/update/delete, refresh summaries
        BlocListener<GetExpensesBloc, GetExpensesState>(
          listener: (context, state) {
            if (state is GetExpensesSuccess) {
              // Refresh summary khi expenses thay đổi
              context.read<GetSummaryBloc>().add(RefreshSummaries());
            }
          },
        ),
      ],
      child: BlocBuilder<GetExpensesBloc, GetExpensesState>(
        builder: (context, expensesState) {
          if (expensesState is GetExpensesSuccess) {
            return BlocBuilder<GetSummaryBloc, GetSummaryState>(
              builder: (context, summaryState) {
                // Fallback to real-time calculation if summaries not available
                OverallSummary overallSummary;

                if (summaryState is GetOverallSummarySuccess) {
                  overallSummary = summaryState.summary;
                } else {
                  // Fallback: calculate real-time from expenses
                  final stats = expensesState.expenses.stats;
                  overallSummary = OverallSummary(
                    summaryId: 'fallback',
                    totalIncome: stats.totalIncome,
                    totalExpense: stats.totalExpense,
                    balance: stats.balance,
                    totalTransactionCount: expensesState.expenses.length,
                    firstTransactionDate: DateTime.now(),
                    lastTransactionDate: DateTime.now(),
                    lastUpdated: DateTime.now(),
                  );
                }

                return Scaffold(
                  appBar: AppBar(toolbarHeight: 0),
                  body: Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top),
                    child: index == 0
                        ? MainScreen(
                            expensesState.expenses,
                            overallSummary: overallSummary,
                          )
                        : index == 1
                            ? CalendarScreen(expenses: expensesState.expenses)
                            : index == 2
                                ? StatsScreen(expensesState.expenses)
                                : const SettingsScreen(),
                  ),
                  bottomNavigationBar: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(30)),
                    child: BottomNavigationBar(
                      onTap: (value) {
                        setState(() {
                          index = value;
                        });
                      },
                      currentIndex: index,
                      selectedItemColor: Colors.blue,
                      unselectedItemColor: Colors.grey,
                      backgroundColor: Colors.white,
                      showSelectedLabels: false,
                      showUnselectedLabels: false,
                      elevation: 3,
                      type: BottomNavigationBarType.fixed,
                      items: const [
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.home), label: 'Home'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.calendar),
                            label: 'Calendar'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.graph_square_fill),
                            label: 'Stats'),
                        BottomNavigationBarItem(
                            icon: Icon(CupertinoIcons.settings),
                            label: 'Settings'),
                      ],
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: FloatingActionButton(
                    onPressed: () async {
                      Expense? newExpense = await Navigator.push(
                        context,
                        MaterialPageRoute<Expense>(
                          builder: (BuildContext context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) =>
                                    CreateCategoryBloc(FirebaseExpenseRepo()),
                              ),
                              BlocProvider(
                                create: (context) =>
                                    GetCategoriesBloc(FirebaseExpenseRepo())
                                      ..add(GetCategories()),
                              ),
                              BlocProvider(
                                create: (context) =>
                                    CreateExpenseBloc(FirebaseExpenseRepo()),
                              ),
                            ],
                            child: const AddExpense(),
                          ),
                        ),
                      );

                      if (newExpense != null) {
                        // Refresh both expenses và summaries
                        context.read<GetExpensesBloc>().add(GetExpenses());
                        context.read<GetSummaryBloc>().add(RefreshSummaries());
                      }
                    },
                    shape: const CircleBorder(),
                    child: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.tertiary,
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.primary,
                          ],
                          transform: const GradientRotation(pi / 4),
                        ),
                      ),
                      child: const Icon(CupertinoIcons.add),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}
