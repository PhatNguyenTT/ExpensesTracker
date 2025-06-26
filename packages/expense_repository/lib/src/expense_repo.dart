import 'package:expense_repository/expense_repository.dart';

abstract class ExpenseRepository {
  // ========== CATEGORY OPERATIONS ==========
  Future<void> createCategory(Category category);

  Future<List<Category>> getCategory();

  Future<void> updateCategory(Category category);

  Future<void> deleteCategory(String categoryId);

  Future<bool> isCategoryInUse(String categoryId);

  Future<List<Expense>> getExpensesByCategory(String categoryId);

  // ========== EXPENSE OPERATIONS ==========
  Future<void> createExpense(Expense expense);

  Future<List<Expense>> getExpenses();

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(String expenseId);

  // ========== INITIAL BALANCE OPERATIONS ==========
  /// Lấy số dư ban đầu hiện tại
  Future<InitialBalance?> getInitialBalance();

  /// Thiết lập số dư ban đầu
  Future<void> setInitialBalance(InitialBalance initialBalance);

  /// Cập nhật số dư ban đầu
  Future<void> updateInitialBalance(InitialBalance initialBalance);

  /// Xóa số dư ban đầu (đặt về 0)
  Future<void> clearInitialBalance();

  /// Kiểm tra xem đã có số dư ban đầu chưa
  Future<bool> hasInitialBalance();

  // ========== SUMMARY OPERATIONS ==========

  // Overall Summary (All-Time)
  Future<OverallSummary> getOverallSummary();

  Future<void> updateOverallSummary(OverallSummary summary);

  /// Lấy Overall Summary với Initial Balance
  Future<OverallSummary> getOverallSummaryWithInitial();

  // Monthly Summary
  Future<MonthlySummary?> getMonthlySummary(int year, int month);

  Future<List<MonthlySummary>> getMonthlyRangeSummary(
      DateTime startDate, DateTime endDate);

  Future<void> upsertMonthlySummary(MonthlySummary summary);

  /// Lấy thông tin số dư đầu/cuối tháng với Initial Balance
  Future<Map<String, dynamic>> getMonthlyBalanceBreakdown(int year, int month);

  // Yearly Summary
  Future<YearlySummary?> getYearlySummary(int year);

  Future<List<YearlySummary>> getYearlyRangeSummary(int startYear, int endYear);

  Future<void> upsertYearlySummary(YearlySummary summary);

  // Daily Summary
  Future<DailySummary?> getDailySummary(DateTime date);

  Future<List<DailySummary>> getDailyRangeSummary(
      DateTime startDate, DateTime endDate);

  Future<void> upsertDailySummary(DailySummary summary);

  // Category Summary
  Future<List<CategorySummary>> getCategorySummaryByMonth(int year, int month);

  Future<List<CategorySummary>> getCategorySummaryByYear(int year);

  Future<CategorySummary?> getCategorySummary(
      String categoryId, int year, int? month);

  Future<void> upsertCategorySummary(CategorySummary summary);

  // ========== BALANCE CALCULATIONS ==========
  /// Tính số dư thực tại một thời điểm cụ thể
  Future<int> getRealBalanceAtDate(DateTime date);

  /// Tính số dư thực hiện tại
  Future<int> getCurrentRealBalance();

  // ========== BATCH OPERATIONS ==========

  /// Recalculate và update tất cả summaries từ raw expenses data
  /// Dùng khi migration hoặc data sync
  Future<void> recalculateAllSummaries();

  /// Update summaries khi có expense mới/cập nhật/xóa
  /// Được gọi tự động khi createExpense/updateExpense/deleteExpense
  Future<void> updateSummariesForExpense(
    Expense expense, {
    Expense? oldExpense, // Để handle update case
    bool isDelete = false,
  });
}
