import 'package:expense_repository/src/models/transaction_type.dart';
import 'package:expense_repository/expense_repository.dart';

/// Extension hỗ trợ thống kê trực tiếp từ danh sách Expense
extension ExpenseStatsHelper on List<Expense> {
  /// Tổng thu nhập (income)
  int get totalIncome => where((e) => e.category.type == TransactionType.income)
      .fold(0, (sum, e) => sum + e.amount);

  /// Tổng chi tiêu (expense)
  int get totalExpense =>
      where((e) => e.category.type == TransactionType.expense)
          .fold(0, (sum, e) => sum + e.amount);

  /// Tổng số dư = income - expense
  int get balance => totalIncome - totalExpense;

  /// Lọc theo tháng & năm cụ thể
  List<Expense> byMonthYear(int month, int year) =>
      where((e) => e.date.month == month && e.date.year == year).toList();

  /// Lọc theo năm
  List<Expense> byYear(int year) => where((e) => e.date.year == year).toList();

  /// Lọc theo categoryId cụ thể
  List<Expense> byCategory(String categoryId) =>
      where((e) => e.category.categoryId == categoryId).toList();

  /// Trả về danh sách thu nhập
  List<Expense> get onlyIncome =>
      where((e) => e.category.type == TransactionType.income).toList();

  /// Trả về danh sách chi tiêu
  List<Expense> get onlyExpense =>
      where((e) => e.category.type == TransactionType.expense).toList();
}
