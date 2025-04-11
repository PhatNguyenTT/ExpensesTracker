import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory();

  Future<void> createExpense(Expense expense);

  Future<List<Expense>> getExpenses();

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(String expenseId);
}
