import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/transaction_type.dart';

class ExpenseStats {
  final int totalIncome;
  final int totalExpense;

  ExpenseStats({
    required this.totalIncome,
    required this.totalExpense,
  });

  int get balance => totalIncome - totalExpense;

  Map<String, dynamic> toJson() => {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'balance': balance,
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
}
