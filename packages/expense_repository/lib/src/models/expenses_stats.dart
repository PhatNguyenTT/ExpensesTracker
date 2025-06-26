import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart';
import 'package:expense_repository/src/models/wallet.dart';

class ExpenseStats {
  final int totalIncome;
  final int totalExpense;

  ExpenseStats({
    required this.totalIncome,
    required this.totalExpense,
  });

  int get balance => totalIncome - totalExpense;

  /// Tính số dư thực với số dư ban đầu của một ví
  int realBalance(Wallet? wallet) {
    final initial = wallet?.initialBalance ?? 0;
    return initial + totalIncome - totalExpense;
  }

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': balance,
      };

  Map<String, dynamic> toJsonWithInitial(Wallet? wallet) => {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': balance,
        'initialBalance': wallet?.initialBalance ?? 0,
        'realBalance': realBalance(wallet),
      };

  factory ExpenseStats.fromExpenses(List<Expense> expenses) {
    final income = expenses
        .where((e) => e.category.type == TransactionType.income)
        .fold(0, (sum, e) => sum + e.amount);

    final expense = expenses
        .where((e) => e.category.type == TransactionType.expense)
        .fold(0, (sum, e) => sum + e.amount);

    return ExpenseStats(totalIncome: income, totalExpense: expense);
  }

  @override
  String toString() =>
      'Thu nhập: $totalIncome, Chi tiêu: $totalExpense, Số dư: $balance';
}

extension ExpenseStatsExtension on List<Expense> {
  ExpenseStats get stats => ExpenseStats.fromExpenses(this);

  /// Tính số dư thực với một ví cụ thể
  int realBalanceWith(Wallet? wallet) {
    final stats = ExpenseStats.fromExpenses(this);
    return stats.realBalance(wallet);
  }
}
