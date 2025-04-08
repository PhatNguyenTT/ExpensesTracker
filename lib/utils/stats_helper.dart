import 'package:expense_repository/expense_repository.dart';

/// Tính tổng thu nhập (chỉ cộng các expense có totalExpenses > 0)
int calculateTotalIncome(List<Expense> expenses) {
  return expenses
      .where((e) => e.category.totalExpenses > 0)
      .fold(0, (sum, e) => sum + e.category.totalExpenses);
}

/// Tính tổng chi tiêu (chỉ cộng các expense có totalExpenses < 0)
int calculateTotalExpense(List<Expense> expenses) {
  return expenses
      .where((e) => e.category.totalExpenses < 0)
      .fold(0, (sum, e) => sum + e.category.totalExpenses.abs());
}

/// Tính số dư: thu nhập - chi tiêu
int calculateBalance(List<Expense> expenses) {
  return calculateTotalIncome(expenses) - calculateTotalExpense(expenses);
}
