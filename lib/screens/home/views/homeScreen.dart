import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_expense_bloc/create_expense_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/get_categories_bloc/get_categories_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/get/get_expenses_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/blocs/create_category_bloc/create_category_bloc.dart';
import 'package:expenses_tracker/screens/addExpense/views/addExpense.dart';
import 'package:expenses_tracker/screens/calendar/calendar.dart';
import 'package:expenses_tracker/screens/home/views/mainScreen.dart';
import 'package:expenses_tracker/screens/profile/profile.dart';
import 'package:expenses_tracker/screens/stats/statsScreen.dart';
import 'package:expenses_tracker/utils/stats_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetExpensesBloc, GetExpensesState>(
        builder: (context, state) {
      if (state is GetExpensesSuccess) {
        final stats = state.expenses.stats;

        return Scaffold(
          appBar: AppBar(toolbarHeight: 0),
          body: Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: index == 0
                ? MainScreen(
                    state.expenses,
                    incomeTotal: stats.totalIncome,
                    expenseTotal: stats.totalExpense,
                    balance: stats.balance,
                  )
                : index == 1
                    ? const CalendarScreen()
                    : index == 2
                        ? StatsScreen(state.expenses)
                        : const ProfileScreen(),
          ),
          bottomNavigationBar: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                    icon: Icon(CupertinoIcons.calendar), label: 'Calendar'),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.graph_square_fill),
                    label: 'Stats'),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.person_solid), label: 'Profile'),
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
                setState(() {
                  state.expenses.insert(0, newExpense);
                });
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
      } else {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
    });
  }
}
