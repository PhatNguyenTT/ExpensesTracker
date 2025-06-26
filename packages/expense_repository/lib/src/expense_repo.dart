import 'package:expense_repository/expense_repository.dart';
import 'package:expense_repository/src/models/wallet.dart';

abstract class ExpenseRepository {
  // ========== WALLET OPERATIONS ==========
  Future<void> createWallet(Wallet wallet);

  Future<List<Wallet>> getWallets();

  Future<Wallet?> getWallet(String walletId);

  Future<void> updateWallet(Wallet wallet);

  Future<void> deleteWallet(String walletId);

  // ========== CATEGORY OPERATIONS ==========
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory();

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String categoryId);

  Future<bool> isCategoryInUse(String categoryId);

  Future<List<Expense>> getExpensesByCategory(String categoryId,
      {String? walletId});

  // ========== EXPENSE OPERATIONS ==========
  Future<void> createExpense(Expense expense);

  Future<List<Expense>> getExpenses({String? walletId});

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(String expenseId);

  // ========== SUMMARY OPERATIONS ==========

  // Overall Summary (All-Time)
  Future<OverallSummary> getOverallSummary(String walletId);

  Future<void> upsertOverallSummary(OverallSummary summary);

  // Monthly Summary
  Future<MonthlySummary?> getMonthlySummary(
      String walletId, int year, int month);

  Future<List<MonthlySummary>> getMonthlyRangeSummary(
      String walletId, DateTime startDate, DateTime endDate);

  Future<void> upsertMonthlySummary(MonthlySummary summary);

  // Yearly Summary
  Future<YearlySummary?> getYearlySummary(String walletId, int year);

  Future<List<YearlySummary>> getYearlyRangeSummary(
      String walletId, int startYear, int endYear);

  Future<void> upsertYearlySummary(YearlySummary summary);

  // Daily Summary
  Future<DailySummary?> getDailySummary(String walletId, DateTime date);

  Future<List<DailySummary>> getDailyRangeSummary(
      String walletId, DateTime startDate, DateTime endDate);

  Future<void> upsertDailySummary(DailySummary summary);

  // Category Summary
  Future<List<CategorySummary>> getCategorySummaryByMonth(
      String walletId, int year, int month);

  Future<List<CategorySummary>> getCategorySummaryByYear(
      String walletId, int year);

  Future<CategorySummary?> getCategorySummary(
      String walletId, String categoryId, int year, int? month);

  Future<void> upsertCategorySummary(CategorySummary summary);

  // ========== BALANCE CALCULATIONS ==========
  /// Tính số dư thực tại một thời điểm cụ thể cho một ví
  Future<int> getRealBalanceAtDate(String walletId, DateTime date);

  /// Tính số dư thực hiện tại cho một ví
  Future<int> getCurrentRealBalance(String walletId);

  // ========== BATCH OPERATIONS ==========

  /// Recalculate và update tất cả summaries cho một ví cụ thể
  Future<void> recalculateSummariesForWallet(String walletId);

  /// Update summaries khi có expense mới/cập nhật/xóa
  Future<void> updateSummariesForExpense(
    Expense expense, {
    Expense? oldExpense,
    bool isDelete = false,
  });
}
