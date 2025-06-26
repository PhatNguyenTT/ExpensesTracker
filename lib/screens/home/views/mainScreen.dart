import 'dart:math';

import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';
import 'package:expenses_tracker/screens/home/blocs/active_wallet_bloc/active_wallet_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/delete/delete_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/blocs/update/update_expense_bloc.dart';
import 'package:expenses_tracker/screens/home/views/view_all_expenses.dart';
import 'package:expenses_tracker/screens/home/views/wallet_selection_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker/utils/currency_formatter.dart';
import 'package:expenses_tracker/screens/stats/stats_helper.dart';
import 'package:expenses_tracker/utils/icon_mapper.dart';

class MainScreen extends StatelessWidget {
  final List<Expense> expenses;
  final OverallSummary overallSummary;
  final Wallet activeWallet;

  const MainScreen(
    this.expenses, {
    super.key,
    required this.overallSummary,
    required this.activeWallet,
  });

  @override
  Widget build(BuildContext context) {
    // Sắp xếp giao dịch một lần và chỉ lấy 3 giao dịch gần nhất
    final recentExpenses = (List<Expense>.from(expenses)
          ..sort((a, b) => b.date.compareTo(a.date)))
        .take(3)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
      child: Column(
        children: [
          // ------------------ Greeting & Settings ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.amber[600]),
                      ),
                      Icon(CupertinoIcons.person_solid,
                          color: Theme.of(context).colorScheme.onSurface)
                    ],
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Xin chào!",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.outline)),
                      Text("Admin",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface)),
                    ],
                  ),
                ],
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(CupertinoIcons.settings_solid))
            ],
          ),
          const SizedBox(height: 20),

          // ------------------ Balance Card ------------------
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => BlocProvider.value(
                    value: BlocProvider.of<ActiveWalletBloc>(context),
                    child: const WalletSelectionScreen(),
                  ),
                ),
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width / 2,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      activeWallet.color.withOpacity(0.8),
                      activeWallet.color,
                    ],
                    transform: const GradientRotation(pi / 4),
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: activeWallet.color.withOpacity(0.4),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    )
                  ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(IconMapper.getIcon(activeWallet.icon),
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(activeWallet.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      formatSignedCurrency(
                          overallSummary.balance + activeWallet.initialBalance),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 13, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Thu nhập
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12.5,
                              backgroundColor: Colors.white30,
                              child: Icon(CupertinoIcons.arrow_down,
                                  size: 12, color: Colors.greenAccent),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Thu nhập',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.white)),
                                Text(
                                    formatSignedCurrency(
                                        overallSummary.totalIncome),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white)),
                              ],
                            )
                          ],
                        ),
                        // Chi tiêu
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 12.5,
                              backgroundColor: Colors.white30,
                              child: Icon(CupertinoIcons.arrow_up,
                                  size: 12, color: Colors.red),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Chi tiêu',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Colors.white)),
                                Text(
                                    formatSignedCurrency(
                                        overallSummary.totalExpense),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white)),
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),

          // ------------------ List giao dịch ------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giao dịch gần đây',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider(
                            create: (context) =>
                                DeleteExpenseBloc(FirebaseExpenseRepo()),
                          ),
                          BlocProvider(
                            create: (context) =>
                                UpdateExpenseBloc(FirebaseExpenseRepo()),
                          ),
                        ],
                        child: ViewAllExpenses(expenses: expenses),
                      ),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.outline),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: recentExpenses.length,
              itemBuilder: (context, int i) {
                final expense = recentExpenses[i];
                final iconData = IconMapper.getIcon(expense.category.icon);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Icon + Tên danh mục
                          Row(children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: expense.category.color,
                                shape: BoxShape.circle,
                              ),
                              child: iconData != null
                                  ? Icon(iconData,
                                      color: Colors.white, size: 24)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              expense.category.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ]),
                          // Giá trị + Ngày
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatSignedCurrency(
                                    expense.category.totalExpenses),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: getAmountColor(
                                      expense.category.totalExpenses),
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yyyy').format(expense.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
