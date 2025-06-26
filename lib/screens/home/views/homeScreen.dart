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
import 'package:expenses_tracker/screens/home/blocs/active_wallet_bloc/active_wallet_bloc.dart';
import 'package:expense_repository/src/models/wallet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;
  String? activeWalletId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ActiveWalletBloc, ActiveWalletState>(
          listener: (context, state) {
            if (state is ActiveWalletLoaded &&
                state.activeWallet.walletId != activeWalletId) {
              activeWalletId = state.activeWallet.walletId;
              context
                  .read<GetExpensesBloc>()
                  .add(GetExpenses(walletId: activeWalletId));
            }
          },
        ),
        BlocListener<GetExpensesBloc, GetExpensesState>(
          listener: (context, state) {
            if (state is GetExpensesSuccess && activeWalletId != null) {
              context
                  .read<GetSummaryBloc>()
                  .add(GetOverallSummary(activeWalletId!));
            }
          },
        ),
      ],
      child: BlocBuilder<ActiveWalletBloc, ActiveWalletState>(
        builder: (context, activeWalletState) {
          if (activeWalletState is ActiveWalletsEmpty) {
            return _buildNoWalletUI();
          }

          if (activeWalletState is ActiveWalletLoaded) {
            return BlocBuilder<GetExpensesBloc, GetExpensesState>(
              builder: (context, expensesState) {
                if (expensesState is GetExpensesSuccess) {
                  return BlocBuilder<GetSummaryBloc, GetSummaryState>(
                    builder: (context, summaryState) {
                      if (summaryState is GetOverallSummarySuccess) {
                        return _buildMainScaffold(
                          context,
                          expensesState.expenses,
                          summaryState.summary,
                          activeWalletState.activeWallet,
                        );
                      }
                      return const Scaffold(
                          body: Center(child: CircularProgressIndicator()));
                    },
                  );
                }
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              },
            );
          }

          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Widget _buildMainScaffold(BuildContext context, List<Expense> expenses,
      OverallSummary summary, Wallet activeWallet) {
    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: index == 0
            ? MainScreen(
                expenses,
                overallSummary: summary,
                activeWallet: activeWallet,
              )
            : index == 1
                ? CalendarScreen(expenses: expenses)
                : index == 2
                    ? StatsScreen(expenses)
                    : SettingsScreen(expenses: expenses),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
          onTap: (value) => setState(() => index = value),
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
                icon: Icon(CupertinoIcons.graph_square_fill), label: 'Stats'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings), label: 'Settings'),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newExpense = await Navigator.push(
            context,
            MaterialPageRoute<Expense>(
              builder: (newContext) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: BlocProvider.of<GetCategoriesBloc>(context),
                  ),
                  BlocProvider.value(
                    value: BlocProvider.of<ActiveWalletBloc>(context),
                  ),
                  BlocProvider(
                    create: (_) =>
                        CreateExpenseBloc(context.read<ExpenseRepository>()),
                  ),
                  BlocProvider(
                    create: (_) =>
                        CreateCategoryBloc(context.read<ExpenseRepository>()),
                  ),
                ],
                child: const AddExpense(),
              ),
            ),
          );

          if (newExpense != null && context.mounted) {
            context
                .read<GetExpensesBloc>()
                .add(GetExpenses(walletId: activeWallet.walletId));
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
  }

  Widget _buildNoWalletUI() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chào mừng bạn!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng tạo một ví để bắt đầu quản lý chi tiêu.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SettingsScreen(
                            expenses: [],
                          )),
                ).then((_) =>
                    context.read<ActiveWalletBloc>().add(LoadActiveWallet()));
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo ví đầu tiên'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
